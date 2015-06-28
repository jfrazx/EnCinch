#
# much of this code was pilfered from Cinch's long dormant 'feature/fish' branch
# https://github.com/cinchrb/cinch/tree/feature/fish
# or from weechat's fish plugin
# https://github.com/weechat/scripts/blob/master/ruby/weefish.rb
# 

module Cinch
  module Plugins
    class EnCinch
      class Encryption
        module Base64
        
          Alphabet = "./0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze

          def self.encode(data)
            res = String.new
            data = data.dup.force_encoding("BINARY")

            data.chars.each_slice(8) do |slice|
              slice = slice.join
              left, right = slice.unpack('L>L>')
              6.times do
                res << Alphabet[right & 0x3f]
                right >>= 6
              end

              6.times do
                res << Alphabet[left & 0x3f]
                left >>= 6
              end
            end

            return res
          end

          def self.decode(data)
            res = String.new
            data = data.dup.force_encoding("BINARY")
            data.chars.each_slice(12) do |slice|
              slice = slice.join
              left = right = 0

              slice[0..5].each_char.with_index do |p, i|
                right |= Alphabet.index(p) << (i * 6)
              end

              slice[6..11].each_char.with_index do |p, i|
                left |= Alphabet.index(p) << (i * 6)
              end

              res << [left, right].pack('L>L>')
            end

            return res
          end
        end


        def initialize(key)
          @blowfish = Crypt::Blowfish.new(key)
        end
        
        def encrypt(text)
          text = pad(text, 8)
          result = String.new
          
          num_block = text.length / 8
          num_block.times do |n|
            block = text[n*8..(n+1)*8-1]
            enc = @blowfish.encrypt_block(block)
            result += Base64.encode(enc)
          end
          
          return "+OK " << result
        end
        
        def decrypt(text)
          return nil if not text.length % 12 == 0
          
          result = String.new
          
          num_block = (text.length / 12).to_i
          num_block.times do |n|
            block = Base64.decode( text[n*12..(n+1)*12-1] )
            result += @blowfish.decrypt_block(block)
          end
          
          return result.gsub(/\0*$/, "")
        end

        def self.generate
          # write some shit to generate a key for key exchange?
        end
        
        private
        
        def pad(text, n=8)
          pad_num = n - (text.length % n)
          if pad_num > 0 and pad_num != n
            pad_num.times { text += 0.chr }
          end

          return text
        end
      end
    end
  end
end
