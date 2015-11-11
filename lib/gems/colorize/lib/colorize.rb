require_relative 'styles'
module Colorize
    
    self::VERSION = "0.0.2"
    
end

class String

    def self.color_set(style=:Terminal)
        style_name = style
        style = Colorize::Style.const_get(style)
        (style::COLORS).keys.each do |meth|
            class_eval %Q[
                def #{meth.to_s.downcase}
                    ::Colorize::Style::#{style_name}.colorize(self, :#{meth})
                end
            ]
        end
    end
    
end

String.color_set