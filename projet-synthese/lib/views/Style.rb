# A class that gather various common colors, fonts and styles used by Pr2pr.
class Style
	
	attr_accessor :bold
	attr_accessor :h1
	attr_accessor :h2
	attr_accessor :gray
	
	# Initialize colors, fonts and styles
	def initialize()
		@bold = Wx::Font.new
		@bold.set_weight(Wx::FONTWEIGHT_BOLD)
		@bold.set_point_size(9)
		
		@h1 = Wx::Font.new
		@h1.set_weight(Wx::FONTWEIGHT_BOLD)
		@h1.set_point_size(12)
		
		@h2 = Wx::Font.new
		@h2.set_weight(Wx::FONTWEIGHT_BOLD)
		@h2.set_point_size(10)
		
		@gray = Wx::Colour.new(120, 120, 120)
	end
end
