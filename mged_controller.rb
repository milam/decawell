require 'geometry'
include Geometry
require 'facets'
require 'ruby-units'
require 'winder'
# require 'constants'
# include Constants::Libraries


parts = %w(chassis lids)
# parts = %w(bobbin_left bobbin_right)
# parts = %w( cutout  lids)

DB = "decawell.g"
mged ="mged -c  #{DB} "

mm = Unit("mm")
amp = Unit("amp")
ohm = Unit("ohm")

# class Unit < Numeric
# 	UNIT_DEFINITIONS = {
# 		'<watt>'  => [%w{watt}, 1.0, :power, %w{<Joule>} , %w{<second>} ]
# 	}
# end
# Unit.setup


scale_factor = 37 # global scaling factor

ribbon_width = 4.2
ribbon_thickness = 0.3 # mm 
turns = 12
minimum_wall_thickness = 2 #mm


outside_radius = (Cube.vertices[0].r) *scale_factor #the distance from the center of the machine to the furthest edge of the core
torus_midplane_radius = (Cube.octahedron[0].r) * scale_factor #distance from the center of the machine to the center of a coil

edge = Cube.edges.first.map{|e|e *scale_factor} # find first edge
a = average(*edge.map{|e|e}) # find midpoint of edge
b = average(*Cube.faces_for_edge.first.first.map{|e|e *scale_factor}) #find center of abutting face
puts "max ring"
puts max_torus = (a-b).r

torus_ring_size = max_torus/1.305 #0.700 *scale_factor # the main torus shape
torus = 0.17 *scale_factor 
torus_negative = 0.72 * torus 
joint_radius = (ribbon_width/2) + (minimum_wall_thickness)
joint_negative_radius = (ribbon_width/2) + 0.05
joint_nudge = 0.87 # this is a percentage scaling of the vector defining the ideal joint location
joint_nudge_length = 0.16
# coil_wire_diameter = 2.053  # mm this 12 gauge AWS
coil_wire_diameter = 1.1  # mm test wire
coil = Coil.new((torus_negative*2), coil_wire_diameter, torus_ring_size)

channel_thickness = (ribbon_thickness*turns)+1

tolerance_distance = 0.01
# tolerance_distance = 0.08

#Joule heating calculations
drive_amps = 2000.0 * amp
wire_resistance = (Unit("1.5883 ohm")/Unit("1000 ft"))  >> Unit("ohm/mm")  # ohms per mm  derived from http://www.eskimo.com/~billb/tesla/wire1.txt
coil_resistance = wire_resistance *(coil.coil_length*mm)
specific_heat_of_copper = (Unit("24.440 J")/Unit("1 mole")/Unit("1 kelvin"))
atomic_weight_of_copper = (Unit("63.546 g")/Unit("mole"))
coil_weight = ((Unit("19.765 lb")/Unit("1000 ft") >> Unit("g/mm"))*(coil.coil_length*mm)) 
coil_weight_in_moles = (coil_weight * atomic_weight_of_copper.inverse)
joule_heating = ((coil_resistance * (drive_amps**2))>>Unit('watt')   )* (specific_heat_of_copper.inverse) *coil_weight_in_moles.inverse


# Ampère's force law calculations  http://en.wikipedia.org/wiki/Ampère%27s_force_law
magnetic_constant = (4*Math::PI * (10.0**-7)) * Unit("newton/ampere**2")
magnetic_force_constant = magnetic_constant / (2*Math::PI)
seperation_of_wires = (torus_midplane_radius*mm) >> Unit("m") # in m
coil_force_per_meter = magnetic_force_constant * ((drive_amps**2)/seperation_of_wires)
coil_force = coil_force_per_meter * (((coil.coil_length)*mm) >> Unit('m'))

#check out wiki: technology applications of superconductors
#Superconductor critical current 
ybco_critical_current = Unit('200 ampere/cm') >>Unit('ampere/mm') #http://www.theva.com/downloads/en/Datasheet_CC.pdf
single_turn = 2*torus_ring_size*Math::PI*mm
ybco_current_density_per_turn = (single_turn * ybco_critical_current)


#test coil
# puts (Unit('5 volts')/(Unit('22 kohm')>>Unit('ohm'))) 
puts( (Unit('1 Joule')/Unit('2 sec')) >> Unit('watt'))



superconducting = {
	:ybco_critical_current => ybco_critical_current, 
	:single_turn => single_turn, 
	:single_turn_12 => single_turn*12 >> Unit('m'), 
	:ybco_current_density_per_turn => ybco_current_density_per_turn, 
}


derived_dimentions = {
	:outside_radius => outside_radius,
	:torus_midplane_radius => torus_midplane_radius,
	:torus_radius => torus_ring_size,
	:torus_tube_radius => torus,
	:torus_tube_wall_thickness => torus-torus_negative,
	:torus_tube_hollow_radius => torus_negative,
	:joint_radius => joint_radius,
	:joint_negative_radius => joint_negative_radius,
	:donut_exterier_radius => torus_ring_size +torus ,
	:donut_hole_radius => torus_ring_size -torus,
}

joule_heating = {
	# :wraps => coil.wraps,
	# :coil_length => (coil.coil_length)*mm,
	# :amp_turn => drive_amps*coil.wraps * Unit("count"),
	# :drive_amps => drive_amps, 
	# :wire_resistance => wire_resistance, 
	# :coil_resistance => coil_resistance, 
	# :specific_heat_of_copper => specific_heat_of_copper, 
	# :atomic_weight_of_copper => atomic_weight_of_copper, 
	# :joule_heating => joule_heating , 
	# :coil_weight_in_moles => coil_weight_in_moles, 
	# :coil_weight => coil_weight, 

	
}

amperes_force = {
	:magnetic_constant => magnetic_constant, 
	:magnetic_force_constant => magnetic_force_constant, 
	:seperation_of_wires => seperation_of_wires, 
	:coil_force_per_meter => coil_force_per_meter, 
	:coil_force => coil_force, 

}


puts "\n\n"
derived_dimentions.select{|k,v| v.class != Unit}.sort_by{|k,v| v}.reverse.each { |k,v| puts "#{k}: #{v} mm"  }
puts "\n\n"

[joule_heating,amperes_force,superconducting].each do |topic|
	puts "\n\n"
	topic.select{|k,v| v.class == Unit}.each { |k,v| puts "#{k}: #{v}"  }
	puts "\n\n"
end


`rm -f ./#{DB.gsub(".g","")}.*`
# `rm ./*.png`
`#{mged} 'units mm'` # set mged's units to decimeter 
`#{mged} 'tol dist #{tolerance_distance}'` #  

coil.grid.each {|row| puts row.map{|c|  c ? 1 : 0}.join("")}
# coil.grid.each {|row|  row.split(false).each{|a| puts a.size}}
coil.grid.each_with_index {|row,index| puts coil.wrap_radius_for_row(index)}

puts "coil start#{coil.truth_array.inspect}"
# coil.wind
# break

if true #parts.include?("chassis")
	
	Cube.octahedron.each_with_index do |v,index| # draw the 12 tori
		v = v*scale_factor
		# `#{mged} 'in torus#{index} tor #{v.mged} #{v.mged} #{torus_ring_size} #{torus}'` #the torus solid
		# in okko eto 0 0 0   1 0 0   3  1 0 0   .6
		
		# `#{mged} 'in torus#{index} eto #{v.mged} #{v.mged} #{torus_ring_size}  #{((v.normal)*((channel_thickness/2)+minimum_wall_thickness)).mged}   #{((channel_thickness/2)+minimum_wall_thickness)} '` #the eto solid

		#determin major axis depending on coil proportions
		major_minor = [((ribbon_width/2+minimum_wall_thickness)),((channel_thickness/2)+minimum_wall_thickness)]
		major_minor = major_minor.reverse if major_minor[0] < major_minor[1]
		

		`#{mged} 'in torus#{index} eto #{v.mged} #{v.mged} #{torus_ring_size}  #{((v.normal)*major_minor[0]).mged}   #{major_minor[1]} '` #the eto solid
		
		`#{mged} 'in torus_negative_outer#{index} rcc #{v.mged} #{(v.inverse.normal*(ribbon_width/2)).mged} #{torus_ring_size+(channel_thickness/2)} '` #the outside radious of the ribbon channel
		`#{mged} 'in torus_negative_inner#{index} rcc #{v.mged} #{(v.inverse.normal*(ribbon_width/2)).mged} #{torus_ring_size-(channel_thickness/2)}'` #the inside radious of the ribbon channel

		`#{mged} 'comb torus_negative#{index}.c u torus_negative_outer#{index} - torus_negative_inner#{index} '` #this hollow center of the torus
		
		`#{mged} 'in lid_knockout#{index} rcc #{v.mged} #{(v.normal*torus ).mged} #{torus_ring_size+torus}'` #this removed the face of the torus so we can install coils
	end
	Cube.edges.each_with_index do |edge,index| #insert the 30 joints
		edge = edge.map{|e|e *scale_factor} # scale the edges
		a = average(*edge.map{|e|e}) # the ideal location of the joint
		a = a * joint_nudge # nudge the joint closer to the center
		b =cross_product(a,(edge[1]-edge[0])) # this is the vector of the half joint
		b = b.normal*scale_factor* joint_nudge_length # get the unit vector for this direction and scale
		`#{mged} 'in joint_#{index} rcc #{(a+b).mged} #{(b.inverse*2).mged} #{joint_radius}'` 
		`#{mged} 'in joint_negative_#{index} rcc #{(a+b).mged} #{(b.inverse*2).mged} #{joint_negative_radius}'` 
	end
	`#{mged} 'comb solid.c u #{(0...Cube.edges.size).map{|index| " joint_#{index} "}.join(" u ")} u #{(0..5).map{|index| "torus#{index}"}.join(" u ")}'` #combine the pieces
	`#{mged} 'comb negative_form.c u #{(0...Cube.edges.size).map{|index| " joint_negative_#{index}  "}.join(" u ")} u #{(0..5).map{|index| "torus_negative#{index}.c u lid_knockout#{index}"}.join(" u ") } '` #combine the pieces
	`#{mged} 'comb chassis u solid.c - negative_form.c'` #combine the pieces
end

if parts.include?("cutout")
	cutout_vector = Dodecahedron.icosahedron[0]
	`#{mged} 'in cutout_shape rcc #{((cutout_vector*scale_factor*0.8).mged)} #{(cutout_vector*scale_factor).mged} #{outside_radius}'` #this hollow center of the torus
	`#{mged} 'comb cutout u chassis + cutout_shape'` #combine the pieces

end



if parts.include?("lids") 
	spacer = 40
	step = Vector[40,0,0]
	(0..0).map do |index| # originallty we needed many lids, but now we only need one
		index1 = index+1
		v = Cube.octahedron.first
		v = v*scale_factor

		`#{mged} 'in torus_negative_outer#{index} rcc #{v.mged} #{(v.inverse.normal*(ribbon_width/2)).mged} #{torus_ring_size+(channel_thickness/2)} '` #the outside radious of the ribbon channel
		`#{mged} 'in torus_negative_inner#{index} rcc #{v.mged} #{(v.inverse.normal*(ribbon_width/2)).mged} #{torus_ring_size-(channel_thickness/2)}'` #the inside radious of the ribbon channel

		`#{mged} 'comb lid_torus_negative#{index} u torus_negative_outer#{index} -  torus_negative_inner#{index} '` #this hollow center of the torus


		`#{mged} 'in lid_lid_knockout#{index} rcc #{v.mged}  #{(v*2).mged} #{torus_ring_size+torus}'` #this removed the face of the torus so we can install coils
		
	end
			`#{mged} 'comb lids u #{(0..0).map{|index| "torus#{index} - lid_torus_negative#{index} - lid_lid_knockout#{index}"}.join(" u ")}'` #combine the pieces

end

# the bobbin 

if parts.include?("bobbin_left")
	offset = Vector[20,0,0]
	wall_thickness = (2.6) # mm
	shaft_radius = (6.35 ) /2.0
	shaft_length = (16 )
	screw_hole_radius = 2 #mm
	screw_hole_position_radius = (torus_ring_size - torus)*0.7 #mm
	notch_origin = shaft_radius -((shaft_radius * 2) - (5.8 )) 
	puts "notch_origin#{notch_origin}"
	puts "wall_thickness: #{wall_thickness}"
	`#{mged} 'in bobbin_torus tor 0 0 0 #{offset.mged} #{torus_ring_size} #{torus_negative+wall_thickness}'` #the torus solid
	`#{mged} 'in bobbin_negative tor 0 0 0  #{offset.mged} #{torus_ring_size} #{torus_negative}'` #this hollow center of the torus
	`#{mged} 'in bobbin_half rcc 0 0 0 #{(offset.normal*torus).mged} #{torus_ring_size}'` #this defines half the torus, so the bobin splits apart
	`#{mged} 'in support_plate rcc 0 0 0 #{(offset.normal*wall_thickness).mged} #{torus_ring_size-torus + wall_thickness  }'` #the plate to the shaft
	`#{mged} 'in shaft_negative rcc 0 0 0  #{(offset.normal*shaft_length).mged} #{shaft_radius  }'` #the plate to the shaft
	`#{mged} 'in shaft_notch rcc #{(Vector[0,notch_origin,0]).mged} #{Vector[0,shaft_length,0].mged}  #{shaft_length*1.2  }'` #the plate to the shaft

	`#{mged} 'in screw_hole rcc 0 #{(screw_hole_position_radius)} 0  #{(offset.normal*shaft_length).mged} #{screw_hole_radius}'` #the screw hole to hold the halves together
	`#{mged} 'in screw_hole2 rcc 0 0 #{screw_hole_position_radius}  #{(offset.normal*shaft_length).mged} #{screw_hole_radius}'` #the screw hole to hold the halves together
	`#{mged} 'mirror screw_hole screw_hole3 y'` #combine the pieces
	`#{mged} 'mirror screw_hole2 screw_hole4 z'` #combine the pieces

	`#{mged} 'in wire_access_notch rcc 0 #{torus_ring_size -torus_negative+5 } 0 #{(Vector[0,0,0] - Vector[0,torus_ring_size -torus_negative ,0]).normal*15} 3'` #combine the pieces


	`#{mged} 'comb shaft_with_notch u screw_hole4 u screw_hole3 u screw_hole2 u screw_hole u shaft_negative - shaft_notch '` # form the shaft with notch
	`#{mged} 'comb bobbin1 u support_plate - shaft_with_notch  u bobbin_torus + bobbin_half - bobbin_negative  '` # form the first half of the bobbin
	`#{mged} 'comb bobbin_left u bobbin1 - wire_access_notch  '` # form the first half of the bobbin

	`cat <<EOF | mged -c #{DB}
	B bobbin_left	
	oed / bobbin_left/bobbin1/bobbin_torus	
	translate #{offset.mged}
	accept
EOF`
	
	
		`#{mged} 'mirror bobbin_left bobbin_right x'` #combine the pieces


# 	`cat <<EOF | mged -c #{DB}
# 	B bobbin	
# 	oed bobbin bobbin_twin
# 	translate #{(Vector[0,0,0] -offset).mged}
# 	accept
# EOF`


	# `#{mged} 'r bobbin_pair u bobbin  u bobbin_twin'` #combine the pieces
end

if parts.include?("lid_with_access")
	`#{mged} 'in lid_with_access_torus#{index} tor #{(step*index1).mged} #{(step*index1).mged}  #{torus_ring_size} #{torus}'` #the torus solid
	`#{mged} 'in lid_with_access_torus_negative#{index} tor #{(step*index1).mged}  #{(step*index1).mged} #{torus_ring_size} #{torus_negative}'` #this hollow center of the torus
	`#{mged} 'in lid_with_access_knockout#{index} rcc #{(step*index1).mged}  #{((step.normal)*torus).mged} #{torus_ring_size+torus}'` #this removed the face of the torus so we can install coils
end



parts.each do |part|

part_with_git_hash = "#{`git rev-parse HEAD`.chomp}_#{part}"	#give the STL output a uniq ID based on git repo hash


`cat <<EOF | mged -c #{DB}
B #{part}
ae 135 -35 180
set perspective 20
zoom .30
saveview ./temp/#{part}.rt
EOF`
	
`./temp/#{part}.rt -s1024`
`mv #{part}.rt.pix ./temp/#{part}.rt.pix` # move this file to the temp directory
`pix-png -s1024 < ./temp/#{part}.rt.pix > ./parts/#{part_with_git_hash}.png` #generate a png from the rt file
`open ./temp/#{part_with_git_hash}.png` # open the png in preview.app


# `g-stl -a 0.005 -D 0.005 -o #{part}.stl #{DB} #{part}` #this outputs the stl file for the part
# `g-stl -a 0.01 -D 0.01 -o #{part}.stl #{DB} #{part}` #this outputs the stl file for the part
# `g-stl -a #{tolerance_distance} -D #{tolerance_distance} -o #{part}.stl #{DB} #{part}` #this outputs the stl file for the part

`g-stl -a #{tolerance_distance} -D #{tolerance_distance} -o ./parts/#{part_with_git_hash}.stl #{DB} #{part}` #this outputs the stl file for the part

# `g-stl -o #{part}.stl #{DB} #{part}` #this outputs the stl file for the part

# `stl-g #{part}.stl #{part}_proof.g`
# `cat <<EOF | mged -c #{part}_proof.g
# B s.#{part}
# ae 135 -35 180
# set perspective 20
# zoom .30
# saveview #{part}.rt
# EOF`
	
# `./#{part}.rt -s1024`
# `pix-png -s1024 < #{part}.rt.pix > #{part}.png` #generate a png from the rt file
# `open ./#{part}.png` # open the png in preview.app


end
