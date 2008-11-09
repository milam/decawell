# 	def icosahedron 
# 
# 		Matrix[
# 			[0, +1, +PHI],
# 			[0, +1, -PHI],
# 			[0, -1, +PHI],
# 			[0, -1, -PHI],
# 			[+1, +PHI, 0],
# 			[+1, -PHI, 0],
# 			[-1, +PHI, 0],
# 			[-1, -PHI, 0],
# 			[+PHI, 0, +1],
# 			[+PHI, 0, -1],
# 			[-PHI, 0, +1],
# 			[-PHI, 0, -1]
# 		]
# 
# # [[Vector[1, 1, 1], Vector[1, 1, -1], Vector[0.618033988749895, 1.61803398874989, 0], Vector[1.61803398874989, 0, 0.618033988749895], Vector[1.61803398874989, 0, -0.618033988749895]], [Vector[1, 1, 1], Vector[1, -1, 1], Vector[0, 0.618033988749895, 1.61803398874989], Vector[0, -0.618033988749895, 1.61803398874989], Vector[1.61803398874989, 0, 0.618033988749895]], [Vector[1, 1, 1], Vector[-1, 1, 1], Vector[0, 0.618033988749895, 1.61803398874989], Vector[0.618033988749895, 1.61803398874989, 0], Vector[-0.618033988749895, 1.61803398874989, 0]], [Vector[1, 1, -1], Vector[1, -1, -1], Vector[0, 0.618033988749895, -1.61803398874989], Vector[0, -0.618033988749895, -1.61803398874989], Vector[1.61803398874989, 0, -0.618033988749895]], [Vector[1, 1, -1], Vector[-1, 1, -1], Vector[0, 0.618033988749895, -1.61803398874989], Vector[0.618033988749895, 1.61803398874989, 0], Vector[-0.618033988749895, 1.61803398874989, 0]], [Vector[1, -1, -1], Vector[1, -1, 1], Vector[0.618033988749895, -1.61803398874989, 0], Vector[1.61803398874989, 0, 0.618033988749895], Vector[1.61803398874989, 0, -0.618033988749895]], [Vector[1, -1, -1], Vector[-1, -1, -1], Vector[0, -0.618033988749895, -1.61803398874989], Vector[0.618033988749895, -1.61803398874989, 0], Vector[-0.618033988749895, -1.61803398874989, 0]], [Vector[1, -1, 1], Vector[-1, -1, 1], Vector[0, -0.618033988749895, 1.61803398874989], Vector[0.618033988749895, -1.61803398874989, 0], Vector[-0.618033988749895, -1.61803398874989, 0]], [Vector[-1, -1, -1], Vector[-1, 1, -1], Vector[0, 0.618033988749895, -1.61803398874989], Vector[0, -0.618033988749895, -1.61803398874989], Vector[-1.61803398874989, 0, -0.618033988749895]], [Vector[-1, -1, -1], Vector[-1, -1, 1], Vector[-0.618033988749895, -1.61803398874989, 0], Vector[-1.61803398874989, 0, 0.618033988749895], Vector[-1.61803398874989, 0, -0.618033988749895]], [Vector[-1, 1, 1], Vector[-1, 1, -1], Vector[-0.618033988749895, 1.61803398874989, 0], Vector[-1.61803398874989, 0, 0.618033988749895], Vector[-1.61803398874989, 0, -0.618033988749895]], [Vector[-1, 1, 1], Vector[-1, -1, 1], Vector[0, 0.618033988749895, 1.61803398874989], Vector[0, -0.618033988749895, 1.61803398874989], Vector[-1.61803398874989, 0, 0.618033988749895]]]
# 	end






Dodecahedron.vertices.each_with_index do |v,index|
	`#{mged} 'in a_#{rand} sph #{v[0]} #{v[1]} #{v[2]} #{torus}'`  
end
finished = []

edges = []
Dodecahedron.vertices.each_with_index do |v,index|
	Dodecahedron.vertices.each_with_index do |v1,index_in|
		finished <<  [v,v1]

		edges << [v,v1] unless v == v1 || 	finished.rindex([v1,v])
	end
end

edges = edges.sort_by{ |edge| (edge[0] - edge[1]).r  }[(0..29)]
edges=edges.map	do |edge|
	puts "OK#{edge[0].class}"
	[Dodecahedron.vertices.rindex(edge[0]),Dodecahedron.vertices.rindex(edge[1])] # find the reverse index

end
# puts "EDGES:#{edges.map{|edge| (edge[0] - edge[1]).r}.join(",")}"
puts edges.inspect




# pentagons = []
# dodecahedron.each_with_index do |v,index|
# 	dodecahedron.each_with_index do |v1,index1|
# 		dodecahedron.each_with_index do |v2,index2|
# 			dodecahedron.each_with_index do |v3,index3|
# 				dodecahedron.each_with_index do |v4,index4|
# 					if [v,v1,v2,v3,v4].uniq_by {|i|i.hash}.size == [v,v1,v2,v3,v4].size # skip vertice combination with the same vertice twice 
# 						a = average(v,v1,v2,v3,v4)
# 						# (	`#{mged} 'in a_#{rand} sph #{a[0]} #{a[1]} #{a[2]} 0.07'`  ) if a.r > 1.3
# 						pentagons << [v,v1,v2,v3,v4] if a.r > 1.3
# 						# puts pentagons.inspect
# 						# break
# 						
# 					end
# 					# dodecahedron.row_vectors().each_with_index do |vin,index_in|
# 					# 	h = vin - v #vector connecting the point pairs
# 					# 	i = v - vin #the inverse of h
# 					# 	e = average(v,vin)
# 					# `#{mged} 'in a_#{index}_#{index_in} sph #{e[0]} #{e[1]} #{e[2]} 0.06'`  rescue nil
# 					# end
# 				end
# 
# 			end
# 		end
# 	end
# end
# 
# 
#  p =pentagons.uniq_by {|p| p.sort_by{|a|a.hash}.map{|b|b.hash}}
#  puts p.inspect
#  puts p.size
# q = p.map do |face|
# 	# puts "OK#{face.size}"
# 	face.map	do |vertex|
# 		
# 		dodecahedron.rindex(dodecahedron.select { |v| v == vertex   }.first) # find the reverse index
# 
# 		
# 	end
# end
# 
# puts q.inspect


# puts pentagons.inspect

# icosahedron.row_vectors().each_with_index do |v,index|
# 	icosahedron.row_vectors().each_with_index do |vin,index_in|
# 		h = vin - v #vector connecting the point pairs
# 		i = v - vin #the inverse of h
# 		if h.r == 2 && i.r ==2 # only render the outer most vertices
# 			puts "index:#{index},index_in:#{index_in}"
# 			# `#{mged} 'in line#{index}_#{index_in} rcc #{v[0]} #{v[1]} #{v[2]} #{h[0]} #{h[1]} #{h[2]} 0.1'` #the icosohedron
# 			a =cross_product(h,v)
# 			b =cross_product(v,a) 
# 
# 			c =cross_product(i,vin)
# 			d =cross_product(vin,c)
# 
# 			b =b * 0.25 #shorten the vectors
# 			d =d * 0.25
# 			# `#{mged} 'in dot#{index}_#{index_in} sph #{b[0]} #{b[1]} #{b[2]} 0.1'` 
# 			# `#{mged} 'in line2#{index}_#{index_in} rcc #{v[0]} #{v[1]} #{v[2]} #{a[0]} #{a[1]} #{a[2]} 0.1'` 
# 			`#{mged} 'in line_right_#{index}_#{index_in} rcc #{v[0]} #{v[1]} #{v[2]} #{b[0]} #{b[1]} #{b[2]} 0.01'` 
# 			`#{mged} 'in line_left_#{index}_#{index_in} rcc #{vin[0]} #{vin[1]} #{vin[2]} #{d[0]} #{d[1]} #{d[2]} 0.01'` 
# 			
# 			e = intersection(v,bv,vin,d+vin)
# 			# puts "OKOK:#{e}"
# 			# `#{mged} 'in dot#{index}_#{index_in} sph #{e[0]} #{e[1]} #{e[2]} 0.1'`  rescue nil
# 			`#{mged} 'in a_#{index}_#{index_in} sph #{v[0]} #{v[1]} #{v[2]} 0.1'`  rescue nil
# 			`#{mged} 'in b_#{index}_#{index_in} sph #{(b+v)[0]} #{(b+v)[1]} #{(b+v)[2]} 0.1'`  rescue nil
# 			`#{mged} 'in c_#{index}_#{index_in} sph #{vin[0]} #{vin[1]} #{vin[2]} 0.1'`  rescue nil
# 			`#{mged} 'in d_#{index}_#{index_in} sph #{(d+vin)[0]} #{(d+vin)[1]} #{(d+vin)[2]} 0.1'`  rescue nil
# 			
# 		end                                                            
# 		
# 	end
# end

# `#{mged} 'in cutaway rcc 1 1 1  2 2 2 3'`   #draw a cutaway sphere
# `#{mged} 'r cutaway1 u polywell_tori - cutaway'` 