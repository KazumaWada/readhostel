require 'rtesseract'
require 'mini_magick'

class TextImageProcessor
  def self.preprocess_image(input_path, output_path)
    Rails.logger.debug "Starting image preprocessing..."
    image = MiniMagick::Image.open(input_path)
  
    # サイズ縮小
    image.resize '1200x1200>'
    image.format('png')
    image.write(output_path)
  
    # ノイズ除去
    image = MiniMagick::Image.open(output_path)
    image.morphology 'Erode', 'Diamond'
  
    # 傾き補正
    image.deskew '40%'
    image.morphology 'Close', 'Octagon'
  
    # 最終出力
    image.write(output_path)
    Rails.logger.debug "Image preprocessing completed. Output: #{output_path}"
    output_path
  end

  def self.process_dynamic_ogp(base, output, content)
    puts base + "🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹"
    puts content + "🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹🇮🇹"
    
    #base画像を開く
    base_image = MiniMagick::Image.open(base)
    puts "base_image📩📩📩📩📩📩📩📩" + base_image 
    #文字を定義
    #append_text = content
    #image.文字をappendする。
    result = base_image.combine_options do |config|
      config.font 'YuGothic-Bold'
      #config.pointsize POINTSIZE
      #config.kerning KERNING
      config.draw "text #{TITLE_POSITION} '#{content}'"
    end

    #pathは、tmpでランダムに出す。(そのうちフォルダ内に10枚貯まったら消すコードを追加する。
    puts output + "🕵️‍♂️🕵️‍♂️🕵️‍♂️🕵️‍♂️🕵️‍♂️🕵️‍♂️🕵️‍♂️"
    result.write(output)
  end
  

end



