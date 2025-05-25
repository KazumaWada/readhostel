class OcrController < ApplicationController
    require 'rtesseract'
  
    def recognize
      if params[:image].present?
        image_path = params[:image].path
  
        begin
          # TesseractでOCR処理 (英語のみ対応)
          ocr = RTesseract.new(image_path, lang: 'eng')
          recognized_text = ocr.to_s
  
          render json: { text: recognized_text }, status: :ok
        rescue => e
          render json: { error: "OCR failed: #{e.message}" }, status: :unprocessable_entity
        end
      else
        render json: { error: 'No image uploaded' }, status: :bad_request
      end
    end
  end
  