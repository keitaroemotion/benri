module Colorize
    module Style
        module Terminal
            COLORS =
                    {
                        :BOLD           => "\e[1m",
                        :FAINT          => "\e[2m",
                        :ITALIC         => "\e[3m",
                        :BLINK_SLOW     => "\e[5m",
                        :BLINK_FAST     => "\e[6m",
                        :NEGATIVE_COLOR => "\e[7m",
                        :STRIKE_THROUGH => "\e[9m",
                        :UNDERLINE      => "\e[4m",
                        :RED            => "\e[31m",
                        :GREEN          => "\e[32m",
                        :YELLOW         => "\e[33m",
                        :BLUE           => "\e[34m",
                        :MAGENTA        => "\e[35m",
                        :CYAN           => "\e[36m",
                        :WHITE          => "\e[37m",
                        :ON_RED         => "\e[41m",
                        :ON_GREEN       => "\e[42m",
                        :ON_YELLOW      => "\e[43m",
                        :ON_BLUE        => "\e[44m",
                        :ON_MAGENTA     => "\e[45m",
                        :ON_CYAN        => "\e[46m",
                        :ON_WHITE       => "\e[47m",
                        :CLEAR          => "\e[39;49;27m"
                    }
            
            def self.colorize(str, color)
                str = "#{COLORS[color]}#{str}"
                str.gsub!(/\e\[39;49;27m/, COLORS[color])
                return str + COLORS[:CLEAR]
            end
        end
        
        module Html
            
            COLORS = 
                    {
                        :ALICE_BLUE             => "#F0F8FF",
                        :ANTIQUE_WHITE          => "#FAEBD7",
                        :AQUA                   => "#00FFFF",
                        :AQUAMARINE             => "#7FFFD4",
                        :AZURE                  => "#F0FFFF",
                        :BEIGE                  => "#F5F5DC",
                        :BISQUE                 => "#FFE4C4",
                        :BLACK                  => "#000000",
                        :BLANCHED_ALMOND        => "#FFEBCD",
                        :BLUE                   => "#0000FF",
                        :BLUE_VIOLET            => "#8A2BE2",
                        :BROWN                  => "#A52A2A",
                        :BURLY_WOOD             => "#DEB887",
                        :CADET_BLUE             => "#5F9EA0",
                        :CHARTREUSE             => "#7FFF00",
                        :CHOCOLATE              => "#D2691E",
                        :CORAL                  => "#FF7F50",
                        :CORN_FLOWER_BLUE       => "#6495ED",
                        :CORN_SILK              => "#FFF8DC",
                        :CRIMSON                => "#DC143C",
                        :CYAN                   => "#00FFFF",
                        :DARK_BLUE              => "#00008B",
                        :DARK_CYAN              => "#008B8B",
                        :DARK_GOLDENROD         => "#B8860B",
                        :DARK_GRAY              => "#A9A9A9",
                        :DARK_GREY              => "#A9A9A9",
                        :DARK_GREEN             => "#006400",
                        :DARK_KHAKI             => "#BDB76B",
                        :DARK_MAGENTA           => "#8B008B",
                        :DARK_OLIVE_GREEN       => "#556B2F",
                        :DARK_ORANGE            => "#FF8C00",
                        :DARK_ORCHID            => "#9932CC",
                        :DARK_RED               => "#8B0000",
                        :DARK_SALMON            => "#E9967A",
                        :DARK_SEA_GREEN         => "#8FBC8F",
                        :DARK_SLATE_BLUE        => "#483D8B",
                        :DARK_SLATE_GRAY        => "#2F4F4F",
                        :DARK_SLATE_GREY        => "#2F4F4F",
                        :DARK_TURQUOISE         => "#00CED1",
                        :DARK_VIOLET            => "#9400D3",
                        :DEEP_PINK              => "#FF1493",
                        :DEEP_SKY_BLUE          => "#00BFFF",
                        :DIM_GRAY               => "#696969",
                        :DIM_GREY               => "#696969",
                        :DODGER_BLUE            => "#1E90FF",
                        :FIRE_BRICK             => "#B22222",
                        :FLORAL_WHITE           => "#FFFAF0",
                        :FOREST_GREEN           => "#228B22",
                        :FUCHSIA                => "#FF00FF",
                        :GAINSBORO              => "#DCDCDC",
                        :GHOST_WHITE            => "#F8F8FF",
                        :GOLD                   => "#FFD700",
                        :GOLDENROD              => "#DAA520",
                        :GRAY                   => "#808080",
                        :GREY                   => "#808080",
                        :GREEN                  => "#008000",
                        :GREEN_YELLOW           => "#ADFF2F",
                        :HONEY_DEW              => "#F0FFF0",
                        :HOT_PINK               => "#FF69B4",
                        :INDIAN_RED             => "#CD5C5C",
                        :INDIGO                 => "#4B0082",
                        :IVORY                  => "#FFFFF0",
                        :KHAKI                  => "#F0E68C",
                        :LAVENDER               => "#E6E6FA",
                        :LAVENDER_BLUSH         => "#FFF0F5",
                        :LAWN_GREEN             => "#7CFC00",
                        :LEMON_CHIFFON          => "#FFFACD",
                        :LIGHT_BLUE             => "#ADD8E6",
                        :LIGHT_CORAL            => "#F08080",
                        :LIGHT_CYAN             => "#E0FFFF",
                        :LIGHT_GOLDENROD_YELLOW => "#FAFAD2",
                        :LIGHT_GRAY             => "#D3D3D3",
                        :LIGHT_GREY             => "#D3D3D3",
                        :LIGHT_GREEN            => "#90EE90",
                        :LIGHT_PINK             => "#FFB6C1",
                        :LIGHT_SALMON           => "#FFA07A",
                        :LIGHT_SEAGREEN         => "#20B2AA",
                        :LIGHT_SKYBLUE          => "#87CEFA",
                        :LIGHT_SLATEGRAY        => "#778899",
                        :LIGHT_SLATEGREY        => "#778899",
                        :LIGHT_STEELBLUE        => "#B0C4DE",
                        :LIGHT_YELLOW           => "#FFFFE0",
                        :LIME                   => "#00FF00",
                        :LIME_GREEN             => "#32CD32",
                        :LINEN                  => "#FAF0E6",
                        :MAGENTA                => "#FF00FF",
                        :MAROON                 => "#800000",
                        :MEDIUM_AQUAMARINE      => "#66CDAA",
                        :MEDIUM_BLUE            => "#0000CD",
                        :MEDIUM_ORCHID          => "#BA55D3",
                        :MEDIUM_PURPLE          => "#9370D8",
                        :MEDIUM_SEAGREEN        => "#3CB371",
                        :MEDIUM_SLATEBLUE       => "#7B68EE",
                        :MEDIUM_SPRINGGREEN     => "#00FA9A",
                        :MEDIUM_TURQUOISE       => "#48D1CC",
                        :MEDIUM_VIOLETRED       => "#C71585",
                        :MIDNIGHT_BLUE          => "#191970",
                        :MINT_CREAM             => "#F5FFFA",
                        :MISTY_ROSE             => "#FFE4E1",
                        :MOCCASIN               => "#FFE4B5",
                        :NAVAJO_WHITE           => "#FFDEAD",
                        :NAVY                   => "#000080",
                        :OLD_LACE               => "#FDF5E6",
                        :OLIVE                  => "#808000",
                        :OLIVE_DRAB             => "#6B8E23",
                        :ORANGE                 => "#FFA5",     
                        :ORANGE_RED             => "#FF4500",
                        :ORCHID                 => "#DA70D6",
                        :PALE_GOLDENROD         => "#EEE8AA",
                        :PALE_GREEN             => "#98FB98",
                        :PALE_TURQUOISE         => "#AFEEEE",
                        :PALE__VIOLET_RED       => "#D87093",
                        :PAPAYA_WHIP            => "#FFEFD5",
                        :PEACH_PUFF             => "#FFDAB9",
                        :PERU                   => "#CD853F",
                        :PINK                   => "#FFC0CB",
                        :PLUM                   => "#DDA0DD",
                        :POWDER_BLUE            => "#B0E0E6",
                        :PURPLE                 => "#800080",
                        :RED                    => "#FF0000",
                        :ROSY_BROWN             => "#BC8F8F",
                        :ROYAL_BLUE             => "#4169E1",
                        :SADDLE_BROWN           => "#8B4513",
                        :SALMON                 => "# FA8072",
                        :SANDY_BROWN            => "#F4A460",
                        :SEA_GREEN              => "#2E8B57",
                        :SEA_SHELL              => "#FFF5EE",
                        :SIENNA                 => "#A0522D",
                        :SILVER                 => "#C0C0C0",
                        :SKY_BLUE               => "#87CEEB",
                        :SLATE_BLUE             => "#6A5ACD",
                        :SLATE_GRAY             => "#708090",
                        :SLATE_GREY             => "#708090",
                        :SNOW                   => "#FFFAFA",
                        :SPRING_GREEN           => "#00FF7F",
                        :STEEL_BLUE             => "#4682B4",
                        :TAN                    => "#D2B48C",
                        :TEAL                   => "#008080",
                        :THISTLE                => "#D8BFD8",
                        :TOMATO                 => "#FF6347",
                        :TURQUOISE              => "#40E0D0",
                        :VIOLET                 => "#EE82EE",
                        :WHEAT                  => "#F5DEB3",
                        :WHITE                  => "#FFFFFF",
                        :WHITE_SMOKE            => "#F5F5F5",
                        :YELLOW                 => "#FFFF00",
                        :YELLOW_GREEN           => "#9ACD32"
                    }
            def self.colorize(str, color)
                return "<span style=\"font-color: #{COLORS[color]}\">#{str}</span>"
            end
		end
		
		module IRC
			XC = "\x3"
			IRC::COLORS = 
					{
						:BOLD           => [?\x2     ,  ?\x2],
						:UNDERLINE      => [?\x1F    , ?\x1F],
						:NORMAL         => [?\xF     ,  ?\xF],
						:WHITE          => [XC+ "00" ,    XC],
						:ON_WHITE       => [XC+",00" ,    XC],
						:BLACK          => [XC+ "01" ,    XC],
						:ON_BLACK       => [XC+",01" ,    XC],
						:BLUE           => [XC+ "02" ,    XC],
						:ON_BLUE        => [XC+",02" ,    XC],
						:GREEN          => [XC+ "03" ,    XC],
						:ON_GREEN       => [XC+",03" ,    XC],
						:PINK           => [XC+ "04" ,    XC],
						:ON_PINK        => [XC+",04" ,    XC],
						:RED            => [XC+ "05" ,    XC],
						:ON_RED         => [XC+",05" ,    XC],
						:PURPLE         => [XC+ "06" ,    XC],
						:ON_PURPLE      => [XC+",06" ,    XC],
						:BROWN          => [XC+ "07" ,    XC],
						:ON_BROWN       => [XC+",07" ,    XC],
						:YELLOW         => [XC+ "08" ,    XC],
						:ON_YELLOW      => [XC+",08" ,    XC],
						:LIGHT_GREEN    => [XC+ "09" ,    XC],
						:ON_LIGHT_GREEN => [XC+",09" ,    XC],
						:TURQUOISE      => [XC+ "10" ,    XC],
						:ON_TURQUOISE   => [XC+",10" ,    XC],
						:TEAL           => [XC+ "11" ,    XC],
						:ON_TEAL        => [XC+",11" ,    XC],
						:LIGHT_BLUE     => [XC+ "12" ,    XC],
						:ON_LIGHT_BLUE  => [XC+",12" ,    XC],
						:VIOLET         => [XC+ "13" ,    XC],
						:ON_VIOLET      => [XC+",13" ,    XC],
						:DARK_GRAY      => [XC+ "14" ,    XC],
						:DARK_GREY      => [XC+ "14" ,    XC],
						:ON_DARK_GRAY   => [XC+",14" ,    XC],
						:ON_DARK_GREY   => [XC+",14" ,    XC],
						:LIGHT_GREY     => [XC+ "15" ,    XC],
						:LIGHT_GRAY     => [XC+ "15" ,    XC],
						:ON_LIGHT_GRAY  => [XC+",15" ,    XC],
						:ON_LIGHT_GREY  => [XC+",15" ,    XC]
					}
			def self.colorize(str, color)
				puts color
				return "#{COLORS[color][0]}#{str}".gsub(/\x3[^\d]/, COLORS[color][0]) + COLORS[color][1]
			end
		end
    end
end
