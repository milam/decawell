# $Id: voltmeter.rb 89 2008-04-08 20:09:05Z bikenomad $
#
# voltmeter.rb: sample program to do multi-channel multi-sample
# analog input and display repeatedly
#
# Displays all 4 differential input channel voltages repeatedly;
#
# If you enter an AO channel number [1/0], a space, and a value, followed by a
# space or CR you will set the analog output as well.
#
#-----------------------------------------------------------------------
# ruby-daqmxbase: A SWIG interface for Ruby and the NI-DAQmx Base data
# acquisition library.
# 
# Copyright (C) 2007 Ned Konz
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#-----------------------------------------------------------------------
#
$suppressStderr = false

BEGIN {
  $:.push("..")
  $stderr.reopen("/dev/null") if $suppressStderr
  trap('INT') { exit }
}

if ARGV[0] == '-h'
  puts "Usage: ruby #{$0} [-d]\n   -d chooses diff channels, else unipolar."
  exit 
end

require 'daqmxbase'
require 'arraystats'

include Daqmxbase

# Task parameters
$aiTask = nil
$aoTask = nil

# Input channel parameters
if ARGV[0] == "-d"
  $aiChans = "Dev1/ai0:3"	# all 4 diff channels
  $nAIChans = 4
  $terminalConfig = VAL_DIFF
  puts("Differential channels 0:3")
else
  $aiChans = "Dev1/ai0:7"	# all 8 unipolar channels
  $nAIChans = 8
  $terminalConfig = VAL_RSE
  puts("Single-ended channels 0:7")
end
$aiMin = 0.0
$aiMax = 2.0
$units = VAL_VOLTS

# Output channel parameters
$aoChans = "Dev1/ao0:1"
$nAOChans = 2
$aoMin = 0.0
$aoMax = 5.0

# Timing parameters
$source = "OnboardClock"
$sampleRate = 1000.0
$activeEdge = VAL_RISING
$sampleMode = VAL_CONT_SAMPS
$numSamplesPerChan = 1000

# Data read parameters
$timeout = 10.0
$fillMode = VAL_GROUP_BY_CHANNEL # or VAL_GROUP_BY_SCAN_NUMBER
$bufferSize = $numSamplesPerChan * $nAIChans

$scanNum = 0

def doOneScan(output)
  $scanNum = $scanNum + 1
  (data, samplesPerChanRead) = readAnalog()
  $nAIChans.times { |c| 
    avg = data[c * samplesPerChanRead, samplesPerChanRead].average
    output.printf("%d: %7.4f    ", c, avg)
  }
  output.printf("  (%6d)\r", $scanNum)
end

def createAITask
  $aiTask = Task.new()
  $aiTask.create_aivoltage_chan($aiChans, $terminalConfig, $aiMin, $aiMax, $units) 
  $aiTask.cfg_samp_clk_timing($source, $sampleRate, $activeEdge, $sampleMode, $numSamplesPerChan)
  $aiTask.cfg_input_buffer($numSamplesPerChan * 10)
  $aiTask.start()
end

def readAnalog
  $aiTask.read_analog_f64($numSamplesPerChan, $timeout, $fillMode, $bufferSize)
end

def createAOTask
  $aoTask = Task.new()
  $aoTask.create_aovoltage_chan($aoChans, $aoMin, $aoMax, VAL_VOLTS)
  $aoTask.start()
end

def writeAnalog(vals)
  $aoTask.write_analog_f64(1, 0, 0.5, VAL_GROUP_BY_CHANNEL, vals)
end


begin
  output = $stdout
  input = $stdin
  input.sync= true
  output.sync= true
  inputLine = ""

  createAITask()

  createAOTask()
  outputVals = [0.0, 0.0]
  writeAnalog(outputVals)

  while true
    doOneScan(output)
    begin
      # process additional input chars for chnum/chval AO setting
      inputLine = inputLine + input.read_nonblock(100)
      inputLine.sub!(/^([01])\s+([0-9.]+)\s*/) { |match|
        chNum = $1.to_i
        chVal = $2.to_f
        outputVals[chNum] = chVal
        writeAnalog(outputVals)
        output.puts("\nwrote #{chVal} to AO#{chNum}")
        ""
      }
    rescue SystemCallError => e
      retry if e.errno == Errno::EAGAIN
    end
  end

rescue  Exception => e
  $stderr.reopen($stdout) if $suppressStderr
  raise
else
 $stderr.reopen($stdout) if $suppressStderr
 p data
end
