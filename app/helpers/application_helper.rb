module ApplicationHelper
 def set_default_meta_tags
  {
    site: "eigopencil", # サイト名
    title: "✏️eigopencil", # デフォルトのタイトル
    description: "英語のアウトプットをあなたの方法で、あなたのペースで。", # デフォルトの説明
    keywords: "英語, 英語学習", # デフォルトのキーワード
    canonical: request.original_url, # 正規URL
    og: {
      title: :title, # Open Graphのタイトル（:titleを指定すると、titleと同じ値が使われる）
      description: :description, # Open Graphの説明
      type: "website",
      url: request.original_url,
      image: image_url("welcome.png") # デフォルトのOGP画像
    },
    # twitter: {
    #   card: "summary", # Twitter Cardのタイプ
    #   site: "@mywebsite", # Twitterのサイトアカウント
    #   image: image_url("welcome.png") # デフォルトのTwitter画像
    # }
    #card: photoは特別な書き方が必要
    #> twitter:image property is a string, while image dimensions are specified using twitter:image:width and twitter:image:height, or a Hash object in terms of MetaTags gems. There is a special syntax to make this work:
   twitter: {
      card: "summary_large_image",
      site: '@https://x.com/imnotkatsuma',
      image: image_url("welcome.png"),

      #https://github.com/kpumuk/meta-tags?tab=readme-ov-file#twitter-cards
      # <meta name="twitter:card" content="photo">
      # <meta name="twitter:image" content="http://example.com/1.png">
     }
  }
end
end
