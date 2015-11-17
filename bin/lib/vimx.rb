class VimX
  def self.usevim(file, vimapp)
    system "#{vimapp} #{file} "
    Encoder.encode file
  end
end

