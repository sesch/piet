require 'piet/carrierwave_extension'

module Piet
  class << self
    VALID_EXTS = %w{ png gif jpg jpeg }

    def optimize(path, opts= {} )
      output = optimize_for(path, opts)
      puts output if opts[:verbose]
      true
    end

    def pngquant(path, opts = {})
      output = pngquant_for(path, opts)
      puts output if opts[:verbose]
      true
    end

    private

    def optimize_for(path, opts)
      if(opts[:format])
        selected_extension = opts[:format].to_s
      else
        selected_extension = extension(path)
      end  
      case selected_extension
        when "png", "gif" then optimize_png(path, opts)
        when "jpg", "jpeg" then optimize_jpg(path, opts)
      end
    end

    def extension(path)
      path.split(".").last.downcase
    end

    def optimize_png(path, opts)
      vo = opts[:verbose] ? "-v" : "-quiet"
      `optipng -o7 #{vo} #{path}`
    end

    def optimize_jpg(path, opts)
      puts "Optimizing jpeg at #{path}"
      vo = opts[:verbose] ? "-v" : "-q"
      max = ""
      max = ("--max=" + opts[:max]) if opts[:max]
      `jpegoptim -f --strip-all #{vo} #{path} #{max}`
    end

    def pngquant_for(path, opts)
      opts.merge!({:force => true})
      vo = if opts.any?
             opts.keys.map{|x| "-#{x}"}.join(" ")
           else
             ""
           end
      out = `pngquant #{vo} 256 #{path}`
      blobs = path.split(".")
      new_path = "#{blobs[0..-2].join(".")}-fs8.#{blobs[-1]}"
      `mv #{new_path} #{path}`
      out
    end
  end
end
