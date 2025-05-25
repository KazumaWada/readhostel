# Sqliteの開発と環境の使い分け
SQliteを選んだ理由は、個人開発なのでそこまで容量は必要ない。ソースコードに含めることができるので管理が楽。
もちろんデメリットもあると思うのですが、それが出てきたらpostgresなどに変えようと思っています。
supabaseなどで無料で使えるかもしれませんが、学習コストなどを考えて、今知っているやり方で実装していこうと思います。

注意点
- 開発用のDBファイルもgitignoreに含める
- 本番のDBファイルはソースコードに含めない。
  必ずgitignoreで実装する。情報漏洩してしまうので。
  情報が増えるとgitが肥大化してしまうので、pullなどのリクエストが遅くなることがある。差分もソースコードではないので毎回新しい変更として.ストレージ制限に引っかかることもある
  pushされるから履歴が雪だるま式に増える。
そのため、sqliteのデータはすべてrenderで管理する。
RAILS_ENV=production rails db:migrate
一旦紙にまとめてから、実装する。

----------------------------------------
easy85.com
85hub.com
# bugs
- sqliteを開発と本番で一緒に使っていたら、困る。
- 
## 新規登録したら、メッセージを送る。(内容はまだ適当でいい)
---
signupページから、userが作られる。
ページを「メールを確認して下さいという表示にする。」
name,email同様にtokenもその場で自動生成してDBに保存。
mailgunのメール変数に上記tokenを設定する。
userがメール(easy85.com/login?confirm_password)からクリックしたら、params[:confirmation_token]でDBと一致していたら、(tokenが同じか？有効期限内か？)
合っていたら、validateをfalse->trueに変えて、loginPathへ通して、tokenをその場で消す。
(validateのtrue,falseによって、signupを失敗してもloginしてしまうという事態を防げる。)

違かったら、エラー文を表示してもう一度signupのサイトにログインさせるかな。
---
to do
✅userのテーブルに、confrimation_token_emailと、validatedを付ける。
✅confirmation_token_emailを生成する関数を書く。
✅mailgunに変数としてそれをつけておく。
(送信されました. /login?confirmation~にしておく)
(ユーザーがクリックする)
[ログインpathにきました]
メールのリンクをクリックしたら、/pre_signup?token=""
そこのpre_signupのコントローラーでtokenを照会して、okだったら
loginへリダイレクト。
(照会せずにログインしてもいける仕様に一応はしている。)
✨続き: 色々と個々のロジックを考える。validatedで、ログインする資格があるかないか。
👮valifiedがないと、どうなるか？
→botが巡回してきて、スパムを貼りにくる。(アダルトだったり自社の宣伝だったり. googleに上位で表示されるためにindexをばら撒く。)


- 認証完了の文字をtokenと一緒だったらメッセージを表示 sessions#new
通常の/loginから来たら何も表示しないようにする。
else

loginのコントローラーに来たら、(sessions#new)そこでvalidatedをtrueにする。
のと、ここら辺でtokenを消しておく。

-　validatedをfalseからtrueにしておく。 
- tokenを消す
























## userの情報を管理する。
- そもそもユーザー情報の管理方法
今現在は、ログインしても誰がいるのかは自分のサイトのGUI上でしか管理する方法を知らない。
これから運営するにあたって、どうやって管理していけばいいのか？
そもそもなぜ管理するのか？
->どれくらいユーザーがいるのか知りたい。不具合があった場合、その人へコンタクトが取れる。
->誰が有料課金で誰が無償課金なのかとか。

ユーザー管理機能として Auth0(IDaaSの一つ)

まずは、自分でログインしたら、メールを送る、忘れたらメールアドレス宛に送る。の一連を車輪の再発明してやってみれば良いんじゃないかな？✨そこに到達できたら、ここに戻ってくるのが良いと思う。

↓
メールをユーザーに送信する。
action mailer使うのか、外部のツールに頼るのか。
Action Mailer: controllerのようにメールのロジックを書ける。(登録確認、お知らせ、パスワードの忘れ)
このaction mailerで、有料ユーザーの確認はできるのかな？
外部のツール: 


✨そもそもメールアドレスがその人のものかを確認する必要がある。[Action Mailer]それを送信して、認証完了までいきたい。

↓
signupして、メール送信、メールのリンクを踏む、ログイン画面へ、ようこそ！
(ちなみにdeviseは使用せずに手作りでやってきたらしい。)
--------------------
user.rbで色々と設定: user登録前に確認トークンを設定
(
  //userテーブルに鍵を設定(メールを送信するときに、このトークンを送る)
  def set_confirmation_token
  self.confirmation_token = SecureRandom.urlsafe_base64
  end
  //user mailerでこんな感じのトークンが発行される
  @url = confirm_url(token: @user.confirmation_token)
  "https://your-site.com/confirm?token=3ksdfJ84jfd-sdfJ34FdfD9"
  //controller側で、そのトークンをuser.find_byで探して、当てはまってたら有効化してログインさせる
)
user_mailer.rbで、下記のメソッドで送るメールの内容を定義user.emailとかも
users_contorlelrで、新規ユーザーをsaveしたら、deliver_later, redirectして
「メールを確認してね」というメールを送る。


ってことは、まとめると、
userが作られたときにランダムなトークンを発行。DBに追加。(DBに追加するためにここでuser.save)
user.email先に、そのトークンを含んだurlのメール内容を送信。(https://your-site.com/confirm?token=xxxxx)->routerの/confirmに飛ばしてそこのparams[:token] = xxxxになる。
userがクリックしたら、そのuserのトークンをDBから探してきて該当してたら「ok!ログイン」のお知らせ
userをログインさせる。

userがログインしたら、トークンをその場で破棄して保存。
だから1回目はtokenで確認してログインできて、2回目はトークンが消えているから、そのままログインできる。

[実装]
mailerは封筒に入れるまでだけど、実際に送信するためには、外部のサービスを利用する必要がある。
mailgun,sendgrid etc
mailgunに入る前に、まずはmailerで実装できてからじゃない？
↓
# Action Mailerについて学ぶ
今分かっていること:
controllerと同じように書ける。
メールを送信する機能は無く、それ以前の枠組みを設定する部分。でもプレビューできる。
分からないこと:
どのcontroller名にすればいいのか、

学んだこと:
Action Mailer: 送信する時に使う
Action Mailbox: 受信する時に使う

controller: 送信する時の値の変数を定義
view: 実際に送信される文面を作成
これらを、user_controller内のcreateアクションで実行する。
また、consoleを使って確認することもできる。
```ruby
irb> user = User.first
irb> UserMailer.with(user: user).welcome_email.deliver_later
```
- mailerのプレビュー
test/mailers/previews/配下にプレビュー用のファイルを作る。
UserMailerだったら、UserMailerPreviewというファイル名にする。
UserMailerPreviewファイル内でUserMailerを呼び出すだけ。
プレビューだから、ダミーのemail adressでも問題ない。
```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
#http://localhost:3000/rails/mailers/user_mailer/welcome_email へアクセスすれば閲覧可能
```

そもそもmailgunを使えば、railsからはAPIだけで良かった。
---------------------

# mailgun
controllerからapiを呼び出す
(railsでは、mailerのclassに書くのが良いとされている user_controllerに直接書くのではなく。)
↓
mailgun httpで全て設定されたものを送信

--------
全体像:
eigopencil.comを登録
mailgunから指示されたDNSを追加登録(ドメインの本人確認のため. サブドメインの方が、サイトとメールサイトで分けられるからおすすめ。)
APIを取得
renderで環境変数を設定
RailsにAPI設定のコードを書く(gem faradayでAPI通信)



- googleログインの実装
- googleログインに伴って、複数経路からのユーザーログイン情報の管理  
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   <div class="text-center mb-2"><%= render 'users/profile' %></div>

  <skip_before_action>

<% if @user.microposts.any? %>
    <div class="col-span-1 col-start-1">
    <% if current_user == @user %>
      <%= render partial: 'microposts/content_navs' %>
    <% end %>
      <%= render partial: 'microposts/micropost' %>
    </div>
    </div>
<% end %>

</div>
  
  
  
  
  -------------------
  
  <!-- 白→グレーの間に入れる波 -->
<div class="w-full overflow-hidden leading-none rotate-180">
  <svg viewBox="0 0 500 150" preserveAspectRatio="none" class="w-full h-[100px]">
    <path d="M0.00,49.98 C150.00,150.00 350.00,-50.00 500.00,49.98 L500.00,0.00 L0.00,0.00 Z" class="fill-gray-50"></path>
  </svg>
</div>

# こんな時eigopencilが役立ちますセクション
```html
<section id="why-eigopencil" class="w-full py-20">
  <div class="container mx-auto px-4">
    <div class="text-center mb-12">
      <h1 class="text-3xl sm:text-5xl text-left sm:text-center font-extrabold text-gray-900 mb-4">
        こんなとき、eigopencilが<span class="text-blue-600">役立ちます</span>
      </h1>
      <div class="mt-5"></div>
    </div>
    
    <div class="max-w-4xl mx-auto space-y-10">

      <!-- 悩みリスト 1 -->
      <div>
        <div class="bg-white p-6 rounded-2xl shadow-md text-left">
          <p class="text-gray-700 text-base font-semibold">🤦‍♂️覚えたいフレーズを、どこに書き留めておけば良いのか分からない。</p>
        </div>
        <p class="text-center text-md font-semibold">↓</p>
        <p class="text-center text-blue-600 text-xl font-bold">✔️ 見つけたフレーズをサクッとメモして整理</p>
      </div>

      <!-- 悩みリスト 2 -->
      <div>
        <div class="bg-white p-6 rounded-2xl shadow-md text-left">
          <p class="text-gray-700 text-base font-semibold">🤦‍♂️ノートに書いたはずのフレーズが埋もれてしまい、探せない。</p>
        </div>
        <p class="text-center text-md font-semibold">↓</p>
        <p class="text-center text-blue-600 text-xl font-bold">✔️ フレーズをタグ管理して見つけられます</p>
      </div>

      <!-- 悩みリスト 3 -->
      <div>
        <div class="bg-white p-6 rounded-2xl shadow-md text-left">
          <p class="text-gray-700 text-base font-semibold">🤦‍♂️自分だけの単語帳を作りたいけど、しっくりくるサービスが見つからない。</p>
        </div>
        <p class="text-center text-md font-semibold">↓</p>
        <p class="text-center text-blue-600 text-xl font-bold">✔️ eigopencilならシンプルで使いやすい</p>
      </div>

    </div>
  </div>
</section>
```

```erb
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>eigoPencil</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@300;400;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Noto Sans JP', sans-serif;
        }
    </style>
</head>
<body class="">

    <!-- Navigation -->
    <nav class="top-0 left-0 right-0 bg-white shadow-md z-50 h-16">
    <div class="container mx-auto px-4 h-full flex justify-between items-center">
      <div class="flex items-center space-x-3 h-full">
        <a href="/" class="flex items-center h-full">
          <%= image_tag "logo.png", class: "h-24 object-contain" %>
        </a>
      </div>
      <div class="space-x-4">
        <%= link_to login_path, data: { turbo: false }, class: "bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition" do %>
          無料で始める
        <% end %>
      </div>
    </div>
  </nav>

  <!-- hero section -->
  <header class="pt-10 text-center">
  <div class="container mx-auto px-4">
<h1 class="text-5xl font-extrabold text-left md:text-left text-gray-800 mb-4">
覚えたい単語やフレーズは、<span class="text-blue-600">eigopencil</span>にメモしておこう
</h1>
      <div class="mt-10 flex justify-center">
      <!-- スマホモックアップ -->
      <div class="relative w-full max-w-[300px] transform transition-all duration-300 rounded-2xl overflow-hidden">
        <%= image_tag "phone-mockup.png", class: "w-full object-cover rounded-2xl" %>
        <div class="absolute inset-0 bg-gradient-to-r from-transparent to-white opacity-30"></div>
      </div>

      <!-- PCモックアップ -->
      <div class="relative w-full max-w-[600px] transform transition-all duration-300 rounded-2xl overflow-hidden hidden md:block">
        <%= image_tag "pc-mockup.png", class: "w-full object-cover rounded-2xl" %>
        <div class="absolute inset-0 bg-gradient-to-r from-transparent to-white opacity-30"></div>
      </div>
    </div>
  </header>




    <div id="title" class="w-full h-screen flex flex-col items-center justify-center text-center pt-10">
    <div class="p-4">
    <h1 class="text-5xl text-left sm:text-center font-extrabold text-gray-900 mb-4">シンプルな<span class="text-blue-600">単語帳サイト</span></h1>
    <div class="mt-8">
    <p class="text-gray-600 text-lg font-bold text-left">✔️ 覚えたい単語やフレーズ、日本語訳、例文をまとめて管理！<br>✔️ タグをつけて管理しやすく<br>✔️ フラッシュカード機能でしっかり定着</p>
    </div>
    <%= image_tag "root_img.png", class: "h-[60vh] object-cover mx-auto" %>
    </div>
   </div>


  <section id="why-eigopencil" class="w-full py-20">
  <div class="container mx-auto px-4">
    <div class="text-center mb-12">
      <!--<h2 class="text-4xl font-extrabold text-gray-800 mb-4">こんなとき、<span class="text-blue-600">eigopencil</span>が役立ちます</h2>-->
      <h1 class="text-5xl text-left sm:text-center font-extrabold text-gray-900 mb-4">こんなとき、eigopencilが<span class="text-blue-600">役立ちます</span></h1>

      <div class="mt-5">
      <!--<p class="text-gray-600 text-lg font-semibold">英語学習中に感じた「ちょっとした困りごと」、ありませんか？</p>-->
      </div>
    </div>
    
    <div class="max-w-4xl mx-auto space-y-10">
      <!-- 悩みリスト -->
      <div class="bg-white p-6 rounded-2xl shadow-md text-left">
        <p class="text-gray-700 text-lg font-bold">🤦‍♂️🎬 映画や動画で出会ったフレーズを、どうやって管理すればいいかわからない。</p>
      </div>

      <div class="bg-white p-6 rounded-2xl shadow-md text-left">
        <p class="text-gray-700 text-lg font-bold">🤦‍♂️📓 ノートに書いたはずのフレーズが埋もれてしまい、探せない。</p>
      </div>

      <div class="bg-white p-6 rounded-2xl shadow-md text-left">
        <p class="text-gray-700 text-lg font-bold">🤦‍♂️🔍 自分だけの単語帳を作りたいのに、しっくりくるサービスが見つからない。</p>
      </div>

      <!-- 解決 -->
      <div class="text-center mt-16">
        <p class="text-4xl font-extrabold text-blue-600 mb-4 relative inline-block">
        ☝️この悩み、eigopencilで解決！
        <span class="absolute left-0 bottom-[-6px] w-full h-1 bg-blue-300 opacity-50"></span>
        </p>
      </div>
      


    </div>
  </div>
</section>


<div id="title" class="w-full h-screen flex flex-col items-center justify-center text-center pt-10">
<div class="p-4">
<h1 class="text-5xl text-left sm:text-center font-extrabold text-gray-900 mb-4">かんたん＆見やすいデザイン<span class="text-blue-600">💆🏻‍♂️</span></h1>
<div class="mt-10">
<p class="text-gray-600 text-lg font-bold text-left"></p>
<p class="text-gray-600 text-lg font-bold text-left">「単語帳として使いたいだけなのに、なぜここまで複雑なんだろう」</p>
<p class="text-gray-600 text-lg font-bold text-left">「もっとシンプルなものを作れるはずだ」</p><br>
<p class="text-gray-600 text-lg font-bold text-left">このような開発者自身の悩みから、英語学習者を支えるためのサービスであるeigopencilが誕生しました。</p>
<!--<p class="text-gray-600 text-lg font-bold text-left">僕もこのサービスの利用者の一人であるため、開発段階で実際に使い込みながらユーザーの目線で使いやすいようなデザインを目指しました。</p>-->
<p class="text-gray-600 text-left">クリックで、{ページ名: 画像}のjsonで、全てのページをユーザーに見せる事ができるようにする。↓</p>
</div>
<%= image_tag "root_img.png", class: "h-[60vh] object-cover mx-auto" %>
</div>
</div>




  <div id="title" class="w-full h-screen bg-blue-500 flex flex-col items-center justify-center text-center pt-10">
  <div class="p-4">
  <section class="rounded-md py-16" id="faq">
  <div class="container mx-auto px-4">
    <h2 class="text-4xl font-extrabold text-center text-white text-gray-800 mb-12">よくある質問</h2>
    <div class="max-w-3xl mx-auto space-y-8">
      
      <div class="bg-white shadow-md rounded-lg p-6">
        <h3 class="text-xl font-semibold text-gray-800 mb-2">eigopencilは無料で使えますか？</h3>
        <p class="text-gray-600">はい、基本機能は無料でご利用いただけます。ユーザーからの支援によってサーバーコストがまかなわれ、運営する事ができています。</p>
      </div>

      <div class="bg-white shadow-md rounded-lg p-6">
        <h3 class="text-xl font-semibold text-gray-800 mb-2">どんな単語やフレーズでも保存できますか？</h3>
        <p class="text-gray-600">もちろんです！映画、ドラマ、読書中に出会った英語など、自由に保存・管理できます。</p>
      </div>

      <div class="bg-white shadow-md rounded-lg p-6">
        <h3 class="text-xl font-semibold text-gray-800 mb-2">スマホでも使えますか？</h3>
        <p class="text-gray-600">はい、eigopencilはスマートフォンにも最適化されているため、快適にお使いいただけます。</p>
      </div>

      <div class="bg-white shadow-md rounded-lg p-6">
        <h3 class="text-xl font-semibold text-gray-800 mb-2">フラッシュカード機能とは何ですか？</h3>
        <p class="text-gray-600">保存した単語やフレーズをクイズ形式で復習できる機能です。記憶の定着をサポートします。</p>
      </div>

    </div>
  </div>
</section>

  </div>
 </div>


    <!-- Features Section -->
    <!--<section id="features" class="py-16 bg-white">
        <div class="container mx-auto px-4">
            <h2 class="text-3xl font-bold text-center mb-12 text-gray-800">eigopencilの特徴</h2>
            <div class="grid md:grid-cols-3 gap-8">
                <div class="bg-blue-50 p-6 rounded-lg text-center">
                    <div class="text-4xl mb-4">🏷️</div>
                    <h3 class="font-bold text-xl mb-4">タグ管理</h3>
                    <p class="text-gray-600">単語やフレーズをカテゴリー別に整理</p>
                </div>
                <div class="bg-blue-50 p-6 rounded-lg text-center">
                    <div class="text-4xl mb-4">📇</div>
                    <h3 class="font-bold text-xl mb-4">フラッシュカード</h3>
                    <p class="text-gray-600">繰り返し学習で効果的に記憶</p>
                </div>
                <div class="bg-blue-50 p-6 rounded-lg text-center">
                    <div class="text-4xl mb-4">📊</div>
                    <h3 class="font-bold text-xl mb-4">学習進捗</h3>
                    <p class="text-gray-600">正解数と学習状況を可視化</p>
                </div>
            </div>
        </div>
    </section>-->



    <!-- CTA Section -->
    <section class="py-16 bg-blue-700 text-white text-center">
        <div class="container mx-auto px-4">
            <h2 class="text-3xl font-bold mb-6">すぐに始められる英語学習</h2>
            <p class="text-xl mb-8">まずは無料で、気軽に英語学習を始めましょう</p>
            <%= link_to login_path, data: { turbo: false }, class: "bg-white text-blue-600 text-xl px-10 py-4 rounded-lg hover:bg-gray-100 transition" do %>
                学習を始める
            <% end %>
        </div>
    </section>

    <!-- Footer -->
    <footer class="py-4">
        <div class="container mx-auto px-4 text-center">
            <p>&copy; <%= Date.current.year %> eigopencil. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>

```

# DBは、sqlitにしておけば、料金はかからないし、supabaseのpostgresを使えば、無料で使用することができる。
# 単語、フレーズを登録。その後に、ホームにやることリストとして、その単語の自作英文を書こうというタスクを追加していく。そのやることリストを無くしていくことでユーザーのドーパミンをヒットさせて維持させていく。

# でもそのあとはどうするか。ただ単に表示させておくだけ？？


# 覚えたフレーズを使って、英語日記を書こう！
フレーズを自分のものにする。
せっかく覚えたかっこいいフレーズを忘れないように使おう。
学校でよく新しい漢字を覚える時に授業で活用していた手法があった。それを参考にした。
覚えたフレーズの太字をクリックしたら、そのカードの詳細ページに飛ぶとか。

# リリースまでにすること
- 日記、下書き、カードを一体化させる。
　- 日記を書いているときも、カードを参考できるようにさせておく。だから下画面とかで。
　- フラッシュカードを太字にする
- ↑まずは自分で使ってみる。うん。別に一緒にしなくてもいいしね。日記いらないかもしれないしね。

# LP
これ参考:https://santa.alc.co.jp/?pid=ALC&c=EJ&af_adset=la

https://votars.ai/ja/?gad_source=1&gclid=Cj0KCQjwhYS_BhD2ARIsAJTMMQZtsLcr13tBQKdUevDcjEAY2CBTwai867eLQVZ5aiSZBES94n8bntAaAt3TEALw_wcB
↑このサイトの色を参考にする。
覚えたい英単語やフレーズと、その日本語訳を書きとめて、フラッシュカードで学習できるサイトです。

こんなお悩みはありませんか？
なみなみ

eigopencilなら見やすいデザインとタグ機能を使って、覚えたかったフレーズをしっかり管理する事ができます！

# 追加機能
- flashは非同期で3秒くらいで消えて欲しい。
- フラッシュカードを選択したときに、
「正解すうが少ない順で出す」
「旅行」とかのタグで出すとか色々とできるようにする。
































tag: カンマ区切り、3つまで。
カンマと空白を切り取って、英語と日本語の点どっちも判断。
tag自体には、"dog, cat, hello"とStringで全て入力させて格納させ、フロントで分ければいい。
だからDB,Modelに特別な操作をさせる必要はない。


navのデザインを考えて決める。
カードの並び替え実装、タグを実装して
リリースする。

### 管理ができるの定義
一覧が見れる
日付順で管理
正解順で管理
タグ別

モチベーション的なもの。どれだけ草を生やしたか。ドーパミン的なもの
# 今後実装するもの
- scrapのデザイン
- 削除するときに「本当に削除しますか?」の設定
- モチベが上がるgithubの草みたいなやつ
- homeのデザインを変える。文章も変える。
- navが美しくないから治す。
- フラッシュカードのquiz時のカードの大枠のデザインいらないのでは?
- 終了するボタンを押したらflashで、「難問やって難問正解しましたよ」的な。
- 単語、フレーズの検索機能とか。


# 紹介ページ(自分の学びたい内容を管理したい,デジタルで手軽に管理したい)
## テーマ一文->eigopencilとは?->こんな悩みない?->もう一度違う言い方で紹介->もっと詳しく紹介->頑張ろう！英語を使えるかっこいい人になろう！
- これは、単語帳で学習する人は使わない。単語帳があるから。
そもそもこれが必要なのは、英語学習に上級者だと思わない?だって初心者は市販の単語帳やればいいんだから。

提案文
- 海外ドラマや映画で覚えたフレーズをすぐに実生活で使いたいと思っても、そのフレーズを整理して復習する方法がわからずに困っていませんか？✅✅
- 自分で見つけた英語表現やフレーズを効率的に覚えたいけれど、管理方法が分からず、時間が経つと忘れてしまうことに悩んでいませんか？✅✅
- 学んだ表現を実際の場面で使いたいと思っているけれど、フレーズをどう整理して、復習すべきか決められないと感じていませんか？✅✅
- ネイティブのような表現やスラングを覚えたいけれど、どこでそれを管理すれば良いのか分からず、学んだ内容を活用できないと感じていませんか？✅
- 英語を仕事やプレゼンテーションで使いたいけれど、専門的なフレーズや用語を効率よく覚えられる方法が見つからないと感じていませんか？✅
- 自分だけのカスタマイズされた英単語帳を作りたいけれど、どのようにデジタルで管理するかアイデアが浮かばない…そんなことはありませんか？
- 手軽に繰り返し学習できるツールがなく、学んだフレーズを忘れてしまいがち…もっと効率的に復習できる方法を探していませんか？✅
- ビジネスシーンや特定の分野で使いたい専門的な英語表現を覚えたくても、独自の単語帳やフレーズ集をデジタルでうまく管理できない…そんな経験はありませんか？✅

- 日常会話で使いたいフレーズを覚えたのに、いざ使う時にどこにメモしたか忘れてしまった経験をしたことはありませんか？

- 聞き覚えた印象的なフレーズや単語を、後で復習したいと思ってもどこにメモするか迷ってしまったことはありませんか？
- フレーズや単語帳をデジタルで管理したいけれど、手間がかかって続かないと感じたことはありませんか？
- 自分が学びたい専門用語やスラングがたくさんあるのに、それを効率よく覚えて使いこなす方法を見つけられずにいませんか？
- 新しい言い回しやフレーズを覚えても、どんどん忘れてしまう…どうすれば記憶に残りやすくなるか悩んでいるあなたにぴったりな方法を探していませんか？
- 英語を上級者レベルで学びたいけれど、日常的に触れられるアドバンスな教材がなくて、学習方法に悩んでいませんか？
- 自分の英語の語彙力を広げたいけれど、特定の分野の言い回しを管理しやすい方法が見つからず、方法を模索して日々を過ごしていませんか？





## fetch
- そもそもなぜfetchを使う必要があるのか。
フロント側で全て取得したDOMのデータ内に、DOMの操作後に変更されているデータがある。
それはバックエンドにも反映させたいから、DOM操作後に変更されたデータを送信する必要がある。

fetchを学んでみたいという動機もある。



### fetchAPI, fetch() (https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)
- promiseベース:
「これから結果がやってくる予定だよ」、保留、実行中、拒否されたなどがある。
- モダンwebの特徴であるCORSに統合されている。
- fetch自体がpromiseを返すため、promiseで使われているthenやcatchを使う。

### CORS
違うポート、プロトコルからリソースをリクエストする際にそのリクエストを許可するかどうかを制御する仕組み。

###　どこのrouterに送ればいいか。
静的に簡単に送る:そこで@userの影響とかを送ればいい。
動的に初めから送る: バックエンド側で簡単にできるbut fetchURLを動的にするのが面倒い
↓
fetchAPIを動的にしよう。

### ✅countをどうやって定義して取得、更新をするか。
DOMで変更した内容を、PATCHで送信して、バックエンド側でも受け取って、それをcontrollerで、post.updateと打って更新する。

### 今どうやって、countのidをフロントとバックエンドで同期させるか。
- まず、fetchを使うやり方を使わずにできるのか考える。
puts "📚📚📚📚📚" , @microposts.published.sample(5).count
これで取れたけど、countは備え付けのcountになっているから、correct_numとかに変えたほうがいい。

###　↑そもそも全部stimulusで実装できるかもしれない。
1. stimulusを使って、データをフロントエンドに送信してみる。
2. 

いや@correct_numを使ったら、それをDOMで操作するだけじゃない?

- DOMで変数の値を変更することができるか?
- データはフロントにあるが、DOMでどうやって持ってくるのか
turbo streamでサーバーの変数の値を変更&&通信
turbo streamsを使って通信して反映させることができる。
- turboの通信結果は、updateアクションに書く必要があるかも。

↓
turboのことを学ぶより、fetchでやってしまったほうがいいかも。こんがらがっている気がするから。学習コストのこともあるから。

# 👑ステルスのformを作ってそれを更新処理の送信をすればいいんじゃない?

1. correct_numを作って表示する
2. hidden_fieldをview側に作ってDOMのなんらかのアクションで送信
それをバックエンドで処理する。(stimulus or turboを使わないといちいちロードする羽目)
{id:correct_num}でやって、最後まで行ったらこのhashmapをもとにformで送信して処理したほうが、早い気がする。たくさん通信するより。

でも簡単なのは、turboで逐一非同期で通信させることかもしれないけど。
(↑まずはこれでやってみる)

- 仕様
2. 各フラッシュカード内にhidden_fieldを作って、turboでいちいち通信していく。
correct_numを作る。
変数の値をDOMで取得。
マルが押されたら、hidden_form、にcount++して送信。(まるボタンが送信ボタン)
(まるを押したら、formとsubmitがどちらも飛ぶ?
それとも👀の時点でformでcount++しておいて、マルが押されたら送信)
↓
丸ボタンが押された時点で押された時点でバックエンドでformの内容設定をしておけばformと送信両方ともできる。

# 今
hotwireよりもfetchで実装したほうが凡庸性がある。だから






## 今やってること
- 何回正解したか見えるようにする。同期させる。
 - バッジをデザインする。done
 - countをDBに加える。done!
 - javascriptの結果を反映させてcount++させる。
  - 本当にfetchでいいのか確かめる。
  - Railsの変数で




- draftからscrapsへ変える。



### zenn fetch
- 何がベストプラクティスなのか。
"Railsの変数をJavascriptへ渡して、処理が終わったらその変数を返す。"
- railsがどうやってフロントへデータを送信するのか
- railsがどのタイミングでデータを送信するのか
- javascript側でボタンが押されたら送信する。
- それをどこで受け取ってどこで処理するのか(postリクエストでそれ用のcontrollerとrouter?)


- micropost.countのidを受け取り、それをDOM内で編集してボタンを押されたらそれをRails側に送信して更新する。


































## quizlet
フラッシュカードは無限にできて、クイズは5回まで無料。その後有料になっている。
これに対してどうやって差別化していくか。


## flashcard
- DOM
queryselector: 概要する最初のelementを返す。 
多分、5回繰り返されるのは、queryselectorの場合でも、raulsがループしている間にブラウザが表示されて、ブラウザが5回読み込まれていると思ったけど、それによってjsが影響を受けて5回同じことをしていると思ったけど、それは違うね。
↓
いや、console.log("hello")でも5回繰り返されていた。

```md
はい、あなたが言っている通りです！これは Hotwire がリアルタイムでブラウザにデータを送信している結果です。

具体的な状況
あなたが使用しているのは Hotwire と呼ばれる Rails のリアルタイムフレームワークで、flashcards_controller.js の中で "hello" という文字列がコンソールに出力されているということは、以下のような流れが発生していると考えられます。

Rails サーバーがデータを送信する準備: サーバー側では、@microposts.published.sample(5) によって、ランダムに選ばれた5つの micropost を処理しています。これらはサーバーサイドで生成されるデータです。

Hotwire が動的にページを更新: flashcards_controller.js は、Hotwire の一部であり、ブラウザ側にリアルタイムで DOM の更新を指示します。つまり、サーバーがレスポンスを返す前に、hello というメッセージをコンソールに表示しているのは、JavaScript が非同期に実行されているからです。

Hotwire は、サーバーサイドで変更があった場合、JavaScript がリアルタイムでその変更をブラウザに反映させます。これにより、ページの内容が更新されると同時に、コンソールにも「hello」が5回表示されたりするわけです。
ループ内でのデータ送信: サーバー側でデータを生成しているときに、そのデータ（例えば5つの micropost）が逐次的にブラウザに送信されている場合、それぞれのデータの更新時に Hotwire がその情報をブラウザにプッシュします。このとき、flashcards_controller.js 内で hello が 5 回表示されるのは、サーバーが 5 回データを送信しているからです。

なぜ5回表示されるか？
おそらく、以下のような理由です：

Rails と Hotwire の同期処理: Hotwire を使用している場合、データが逐次的にブラウザに送信されるため、flashcards_controller.js 内のコードが5回実行されるのです。例えば、サーバーから送信された5つの micropost ごとに処理が行われ、そのタイミングで "hello" が出力されていると考えられます。

ページの部分的な更新: Hotwire は通常、ページ全体を再読み込みするのではなく、部分的に更新を行います。flashcards_controller.js が関連する部分の DOM を更新する度に、コンソールのログが出力されるのです。これにより、データの送信とともに5回の console.log("hello") が表示されます。

これは普通の動作ですか？
はい、普通の動作です。特に Hotwire のようなフレームワークを使っている場合、サーバーからクライアントに送信されるデータや更新が動的であるため、更新の度にコンソール出力が行われることはよくあります。

まとめ
Rails と Hotwire の仕組み: サーバーサイドでデータを処理し、その結果をリアルタイムでブラウザに反映するため、flashcards_controller.js 内で何度も処理が実行され、その都度コンソールに "hello" が表示されている。
データが逐次的にブラウザに送信されている: サーバー側のループが実行される中で、Hotwire がその結果をブラウザに送信し、JavaScript がそれを受け取って処理しています。
これが意図した動作であれば問題ありませんが、もしこの動作が不要であれば、Hotwire の更新のタイミングを調整したり、console.log の実行場所を調整する必要があるかもしれません。
```
↓
じゃあどうするか?
html要素のscriptタグに直接書けば、リアルタイムレンダリングは行われない。




































## uiを変える。

"/:slug"
ユーザー名
モチベーションが上がるポイント等
[学習を開始する]
4.フラッシュカードを作る(メイン)紙に書いたり、zenn用に書いておく。
5.?ボタンを作って解説をする。rootの紹介を書き換える。
↑土日

なぜこれをやるか?
→ただのアウトプット用ではなく、英単語、フレーズを覚えてくれるためのアプリだから、みんなの投稿画面はいらない。
そして、画面を何個も用意するのではなく、一つで完結させた方がユーザーも理解しやすい。
そしてクイズ画面も作るから、どんどんページを少なくした方がいい。

とりあえずこのデザインの方が、ユーザーも自分もわかりやすいからそうやろうとしている。収益化も考えているから。

















































## 📷zennOGP動的に実装していく。(視覚的なマーケティング用)
 ogpを作る理由。シェアした時にパッとogpが見えると、それだけで文字よりも圧倒的にアテンションを得られるから。


そもそもogpは、なぜリンクを貼っただけで画像が表示されるのかというと、x側がリンクを認識した時点でそのリンク宛にhttpリクエストを送っているから。
つまり、/post/:idに送られたらpost_controllerのshowアクションにアクセスが行くことになる。


### 決定
- post/:idページで、シェア画像を作成するボタンを押す。(こんな感じになりますという画像を表示する。)それが押されない限りOGPは作られない。


そしたら動的になった場合、どうやってmetaタグに書けば良いのか、について軽く確認した後にminimagickを実装していく。



```md
ボタンを押したら、どうやってpost/:idコントローラへ行くようになるの??
click -> generate_image_path(content)->色々と処理->画像が生成されたら、それをogpに動的に設置して、xを開かせる。(同期させてやらないと、urlをxに書いても処理できていない場合は表示されない。)

post/:idというリンクがtwitter(以下x)に貼られたらx側が、post/:idに対してhttpリクエストを送られてくる。

post/:idに対するコントローラー、つまりpost_controller内のshowが呼び出される。

そして画像処理の関数(post.content)をその関数内に書く。
その関数はどこかのhelperに存在して、その関数は画像処理と、画像の保存場所の指定と保存を実行して返す。


どんな感じでgenerate_dynamic_ogpからshowコントローラーに移動させるんだろう??
showに帰ってきたら、if文で、こんな感じにする

if(画像が画像処理の関数で指定したpathに存在するか?)その画像をogpの動的なimageに設定する。つまりogpのimageには画像が生成されたpathを指定している。
else 特に何もしない。

こんな感じで、post/:idをx上で書けば、ユーザーが画像処理のボタンを押したら表示されて、押さなかったら、特に何も起こらないみたいな設定ができると思う??

,,,ボタンを押したら、自動的にxに移動してリンクを貼って画像が表示されるようにする過程も足しておく。

ってことは、画像を処理している間は時間がかかるから、ユーザーが何をやっているか認識できるようにする。

画像処理でエラーが起こったら、失敗しましたのメッセージを出したりする。

キャッシュ、非同期とか色んな課題があると思うけど、まずは

ogpを実際に作成して、
```
関数とか、流れは書いた。次は、関数の中身を実装していく。
↓

### minimagick(imagemagickのwrapper)実装
---
doc:
MiniMagick gives you access to all the command line options ImageMagick has(https://www.imagemagick.org/script/command-line-options.php)
ってことはminimagickにコマンドがなくても、imagemagickにあれば使える。
↓
ImageMagick command-line tool has to be installed. You can check if you have it installed by running
imagemagickがインストールされている必要がある。
imagemagickはrubyではなく、もっと低レイヤの話なのかもしれない。
↓
Cで書かれていた。
https://github.com/imagemagick/imagemagick
↓
ってことはdockerでimagemagickをダウンロードすることになりそう。

```docker
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      省略
        imagemagick && \
      省略
```
無事追加。

- 実際に使ってみる。
minimagickの書き方が嫌だったら、imageMagickをこの書き方でそのまま実行できる。こっちの方がパフォーマンスが上がるからおすすめとも書いている。
```ruby
# https://github.com/minimagick/minimagick?tab=readme-ov-file#tools
MiniMagick.convert do |convert|
  convert << "input.jpg"
  convert.resize("100x100")
  convert.negate
  convert << "output.jpg"
end #=> `magick input.jpg -resize 100x100 -negate output.jpg`

# OR

convert = MiniMagick.convert
convert << "input.jpg"
convert.resize("100x100")
convert.negate
convert << "output.jpg"
convert.call #=> `magick input.jpg -resize 100x100 -negate output.jpg`
This
```
---


```ruby
  #これは文字列の調節だが、minimagickのdocには存在しなかった。多分imagemagick
    result = base_image.combine_options do |config|
      config.font 'YuGothic-Bold'
      config.pointsize POINTSIZE フォント
      config.kerning KERNING 文字の間隔
      config.draw "text #{TITLE_POSITION} '#{title}'"
    end
```
https://usage.imagemagick.org/text/#label
https://github.com/minimagick/minimagick/issues/150
分かりやすそう↓
https://zenn.dev/redheadchloe/articles/1b7b04a8f984dc

- combine_options使っている人多かった。
- imagemagickがダウンロードされている必要がある


では実際に文字列を写真の上に置いて、画像を加工するものを作ってみる。
まずはimagemagickでその類のコマンドがあるか調べる。そして、上記のminimagick上でもimagemagickの書き方で実装していく。

↓

この記事いいかも。ちゃんとimageMagickの書き方しているし。
https://zenn.dev/mybest_dev/articles/f731b4fc0c3c4f

↓

どうやらdrawメソッドがいいらしい。docを探す。
起点とする位置情報などはgravity

draw:
https://usage.imagemagick.org/draw/
その中のこの2つのセクションを見るといいかも。
https://usage.imagemagick.org/draw/#text
https://imagemagick.org/script/command-line-options.php?#draw

gravity
https://imagemagick.org/script/command-line-options.php#gravity

```
-draw "text 100,100 'Works like magick!'"
```

↓
色々と一気にやるとあれなので、まずはbase_imageをそのままogpとして出力できるかやってみよう。

```md

```






















## zenn OGPキャッシュの問題







































## 🙆🏻‍♂️eigopencilサービス核
核を決めた方がいい。「書いたフレーズを何回も復習して自分のものにするサービス」これが核で、それ以外の機能は捨てて、まずはこれに集中した方がいい。

みんなの投稿が見れる画面は必要ないよね。->ログインしていたら、userページに飛ばす。

duolingoみたいに、総合ポイントで順位をつけて、eigopencilのhomeにはる
userページに「投稿」「みんなの投稿を見る」ボタンをつけて、みんなの投稿が見れるのはプレミアム。下書きもプレミアム。

アクセスが集まってきたら、自分のアプリ内に広告をつけれる箇所を設置して売る。

eigopencil

アウトプットは、他でもできるじゃん。サイトを作るなら、クイズとかの付加価値をつけないと。アウトプットではなく、自分の身に付けたいから、それを実装する。自分はどうやって覚えたいか考える。これは就職するまではプレミアム会員にする。

↑

これらの構造をzennにまとめる。

root
開始ボタンで、今まで自分で書いたやつのフラッシュカードとかを作る。
まるばつで自分で判断してもらって、
何か科学的な記憶のやつに基づいて何回正解したらオッケーとかにする。
各投稿に何回正解したかのカードとかを設置する。































 # OGP

  <!-- Twitter特有 -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="英語のアウトプットをあなたの方法で、あなたのペースで。">
  <meta name="twitter:image" content="https://www.eigopencil.com/assets/welcome.png">
   <!-- Open Graph X以外でも対応-->
  <meta property="og:title" content="静的なページタイトル">
  <meta property="og:description" content="このページの説明文をここに書きます。">
  <meta property="og:image" content="http://example.com/images/default_image.jpg">
  <meta property="og:type" content="website">
  <meta property="og:url" content="http://example.com/">


 # root LP
 ``` ruby

<!-------what is eigopencil?--------------->
<div class="min-h-screen">

  <div class="text-center mt-6">
  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-9 mx-auto">
  <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
  </svg>
  <h1 class="text-2xl font-bold text-gray-800">
  eigopencil.comとは？
  </h1>
  </div>

  <div class="text-center mt-6">
    <p class="m-2">
    あなたが学習した英語の内容(英単語、フレーズ、短い文章からブログのような長文など)を投稿し、その内容が登録したメールアドレスへ後日送られるサービスです。
    </p>
  </div>

 <div class="text-center m-6">
 <%= image_tag("theme03.webp", class: "mx-auto max-w-[320px] h-auto rounded-lg") %>

 </div>

</div>



<!-------users problem--------------->
<div class="min-h-screen">

  <div class="text-center mt-6">
  <h1 class="text-2xl font-bold text-gray-800">
  「せっかく時間をかけて英語を勉強したのに、いざ使おうとしたら単語が出てこない…」そんな経験、ありませんか？
  </h1>
  </div>

<div class="text-left mt-6">
  <ul>
  <li>😥 仕事や学校に追われ自ら復習する気力がない</li>
  <li>😥 どこを学習したのか、忘れてしまっている</li>
  <li>😥 復習をしようと思っても、モチベーションが続かない</li>
  <li>😥 復習する時間があったら、新しい内容を学びたい気持ちを抑えられない</li>
  <li>😥 復習を習慣化できていない</li>
  </ul>
  </div>
  <div class="text-center mt-6">
    <p class="m-2">
    「研究によると、人間は覚えたことの約70%を24時間以内に忘れてしまうと言われています。

(**エビングハウスの忘却曲線:** https://en.wikipedia.org/wiki/Forgetting_curve)

つまり、復習をしなければ、せっかく勉強した内容もほとんど無駄になってしまうのです。
    </p>
  </div>

 <div class="text-center m-6">
 <%= image_tag("theme03.webp", class: "mx-auto max-w-[320px] h-auto rounded-lg") %>
 <p class="text-xl font-bold">では、どうすればいいのでしょうか?</p>
 <p class="text-xl font-bold">
 それは、適切なタイミングで復習を重ねることです。そうすることで、知識はしっかりと定着します！(間隔反復（Spaced Repetition: https://en.wikipedia.org/wiki/Spaced_repetition 学術論文: https://journals.sagepub.com/doi/10.1111/j.1467-9280.2008.02209.x 論文を引用したブログ: https://fs.blog/spacing-effect/ 本: https://www.amazon.com/Make-Stick-Science-Successful-Learning/dp/0674729013 ブログ: https://e-student.org/spaced-repetition/)
 </p>
 <p class="text-xl font-bold">
 そこで、あなたが学習した内容を時間が経った後にリマインドしてくれるようなツールがあったら便利だと思いませんか?そこで、こんな人に向けて、eigopencilを作りました。
 </p>
 </div>

</div>


<!-------solution--------------->
<div class="flex items-center justify-center min-h-screen">
  <div class="text-center">
    <h1 class="text-xl font-semibold text-gray-800 mb-2">
    eigopencil.comは、あなたが投稿した学習内容を後日、自動でリマインドします。あなたはメールの通知をONにすればいいだけです！
    </h1>
  </div>
</div>

<!-------detail about app(price, how to use, )--------------->
<div class="flex items-center justify-center min-h-screen bg-gray-100">
  <div class="text-center">
    <h1 class="text-xl font-semibold text-gray-800 mb-2">
    使い方は簡単！
    </h1>
    <p class="text-gray-500">
    こうやって、こうやってこうやるんです!
    </p>
  </div>
</div>


<!-------action--------------->
<div class="flex items-center justify-center min-h-screen bg-gray-100">
  <div class="text-center">
    <h1 class="text-xl font-semibold text-gray-800 mb-2">
    eigopencilを活用して、英語ができるかっこいい大人になろう！
    </h1>
    <p class="text-gray-500">
    **￥**1000 / 月額

    　　　　　　　　　　　　　サブスクリプション料金(税込)
    
    　　　　　　　　　　　　　　　　ボタンとかstripe
    </p>
  </div>
</div>


<!-------get in touch--------------->
<div class="flex items-center justify-center min-h-screen bg-gray-100">
  <div class="text-center">
    <p class="text-gray-500">
    ニュースレターのwaitlist登録をもう一度ここで確認させる。
    </p>
  </div>
</div>

-----------------------------------------------------------------------

<head>
  <!-- TailwindCSS -->
  <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-50 text-gray-800">

<section class="min-h-screen flex flex-col justify-center items-center py-16 bg-blue-50">
<div class="text-center mb-6">
  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="mx-auto w-16 h-16">
    <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125" />
  </svg>
  <h1 class="text-2xl font-bold text-gray-800">eigopencil.com</h1>
</div>

<div class="text-center mb-6">
  <h2 class="text-3xl font-bold text-gray-800 mb-2">
    勉強した英語はもう<span style="color: #0057ff;">忘れない！</span>復習を自動化して<span style="color: #0057ff;">確実に</span>定着させよう。
  </h2>
  <p class="m-2 text-xl">
    必要なのはスマホまたはPCのみ。あなたの学習した内容が後日メールへ届きます。
  </p>
</div>

<div class="text-center mt-6">
  <p class="text-gray-500">
    eigopencil.comはただいま開発中です。リリース情報を受け取るために、下記フォームにメールアドレスを登録してください！
  </p>
</div>

<!-- Email Sign-up Form -->
<div class="mt-8">
  <form class="flex justify-center gap-4">
    <input type="email" placeholder="あなたのメールアドレス" class="px-4 py-2 rounded-full text-gray-800 focus:outline-none focus:ring-2 focus:ring-blue-500 w-72" required>
    <button type="submit" class="px-6 py-2 bg-blue-600 text-white rounded-full hover:bg-blue-700 transition">登録</button>
  </form>
</div>
</section>


  <!-- What is eigopencil? Section -->
  <section class="min-h-screen bg-gray-100 py-16">
    <div class="text-center mb-6">
      <h2 class="text-3xl font-bold text-gray-800">eigopencil.comとは？</h2>
    </div>

    <div class="text-center max-w-2xl mx-auto mb-6">
      <p class="text-lg text-gray-700">eigopencil.comは、あなたが学習した英語の内容を投稿し、その内容を後日自動でメールにてお届けするサービスです。あなたの学習を継続的にサポートします。</p>
    </div>

    <div class="text-center">
      <img src="https://via.placeholder.com/320x200" alt="eigopencil screenshot" class="mx-auto max-w-[320px] rounded-lg shadow-lg">
    </div>
  </section>

  <!-- Users' Problems Section -->
  <section class="min-h-screen py-16 bg-white">
    <div class="text-center mb-6">
      <h2 class="text-3xl font-bold text-gray-800">「せっかく勉強したのに、いざ使おうとしたら単語が出てこない…」そんな経験、ありませんか？</h2>
    </div>

    <div class="max-w-2xl mx-auto text-left text-lg">
      <ul class="space-y-4 text-gray-700">
        <li>😥 仕事や学校に追われ自ら復習する気力がない</li>
        <li>😥 どこを学習したのか、忘れてしまっている</li>
        <li>😥 復習をしようと思っても、モチベーションが続かない</li>
        <li>😥 復習する時間があったら、新しい内容を学びたい気持ちを抑えられない</li>
        <li>😥 復習を習慣化できていない</li>
      </ul>
    </div>

    <div class="text-center mt-8">
      <p class="text-lg text-gray-600">人間は、覚えたことの約70%を24時間以内に忘れてしまうと言われています。<a href="https://en.wikipedia.org/wiki/Forgetting_curve" class="text-blue-600">エビングハウスの忘却曲線</a>をご覧ください。</p>
    </div>

    <div class="text-center mt-8">
      <p class="text-xl font-bold">では、どうすればいいのでしょうか?</p>
      <p class="text-xl font-semibold mt-4 text-gray-700">それは、適切なタイミングで復習を重ねることです！</p>
      <p class="mt-4 text-lg text-gray-600">eigopencilは、あなたが学習した内容を効果的にリマインドし、記憶を定着させるお手伝いをします。</p>
    </div>
  </section>

  <!-- Solution Section -->
  <section class="min-h-screen bg-blue-50 py-16">
    <div class="text-center mb-6">
      <h2 class="text-3xl font-bold text-gray-800">eigopencil.comは、あなたの学習内容を後日リマインドします！</h2>
      <p class="mt-4 text-lg text-gray-700">投稿した内容が自動でメールで届くので、復習を自動化できます。</p>
    </div>

    <div class="text-center">
      <button class="px-6 py-2 bg-blue-600 text-white rounded-full hover:bg-blue-700 transition">今すぐ始める</button>
    </div>
  </section>

  <!-- Pricing Section -->
  <section class="min-h-screen bg-gray-100 py-16">
    <div class="text-center mb-6">
      <h2 class="text-3xl font-bold text-gray-800">使い方は簡単！</h2>
      <p class="text-lg text-gray-600 mt-4">あなたの学習内容を投稿するだけ！後は自動的にリマインドされます。</p>
    </div>

    <div class="text-center mt-8">
      <h3 class="text-xl font-semibold text-gray-800">月額料金</h3>
      <p class="text-2xl font-bold text-blue-600 mt-2">￥1000 / 月額（税込）</p>
    </div>

    <div class="text-center mt-8">
      <button class="px-6 py-2 bg-blue-600 text-white rounded-full hover:bg-blue-700 transition">今すぐ登録</button>
    </div>
  </section>

  <!-- Footer Section -->
  <section class="min-h-screen bg-blue-600 py-16 text-white text-center">
    <p>ニュースレターの最新情報を受け取るために、以下から再度登録してください。</p>

    <div class="mt-8">
      <form class="flex justify-center gap-4">
        <input type="email" placeholder="あなたのメールアドレス" class="px-4 py-2 rounded-full text-gray-800 focus:outline-none focus:ring-2 focus:ring-blue-500 w-72" required>
        <button type="submit" class="px-6 py-2 bg-blue-700 text-white rounded-full hover:bg-blue-800 transition">登録</button>
      </form>
    </div>
  </section>

</body>
 ```
 # home#index
 ```ruby
 <div class="text-center mt-3" id="nav-section">
  <% if current_user.nil? %>
    <p>hey, ゲストさん! 
      <%= link_to "ログイン", login_path, class: "text-decoration-none text-blue-500" %>
    </p>
  <% else %>
    <div class="flex items-center justify-between w-full">
      <span></span> <!-- Left side empty space -->
      <span class="text-center flex-grow">
        hey, <%= current_user.name %>👋
      </span>
    </div>
  <% end %>
</div>

<div class="mt-5">
<%= render template: "microposts/index" %>
</div>
 ```
# xカードの実装
metaタグ
https://github.com/kpumuk/meta-tags
ogp(open graph protocol) cardを表示させるための機能
https://ogp.me/
xドキュメント
https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/abouts-cards
https://developer.x.com/en/docs/x-for-websites/cards/overview/summary-card-with-large-image
https://developer.x.com/en/docs/x-for-websites/cards/guides/getting-started

is card verifyed??
https://cards-dev.x.com/validator

- ogpメタタグとlink_toの関係
お互い直接通信しているわけでは無い。
ogp: URLがシェアされた時に感知
link_to: xへのリンクを生成するコード

link_toでxへの投稿画面にデータを入力する
↓
ユーザーが投稿する。
↓
xがそのリンク先をクロールし、OGPメタタグを読み取る。
それに基づいてxがリッチなプレビューカードを表示する。
↓
つまり、link_toでxの投稿画面に入力されたデータを、ogpが制御している。

# 文字数、太字テキストエリア

```ruby
<div id="post" class="mt-5 m-2">
  
  <!-- ツールバー -->
  <div class="toolbar mb-2 flex justify-between items-center">
    <div class="flex space-x-2">
      <button class="px-4 py-2 rounded-md" id="bold-button">
        <strong>B</strong>
      </button>
      <!-- 他のフォーマットボタンもここに追加可能 -->
    </div>
    <div class="text-sm text-gray-600" id="char-count">0 / 1000</div>
  </div>
  
  <!-- フォーム -->
  <%= form_with(model: @micropost, url: zen_create_path(slug: @user.slug), method: :post, local: true, html: { class: "micropost-form" }) do |f| %>
    <!-- 編集エリア -->
    <div class="field">
      <div
        id="editor"
        contenteditable="true"
        class="p-4 rounded border shadow-md hover:shadow-lg transition-shadow duration-300 w-full h-[400px]"
        data-placeholder="I have pen, I have an apple Uh! Apple-pen"
        style="min-height: 100px; overflow-y: auto;"
      >
        I have pen, I have an apple Uh! Apple-pen
      </div>
      <!-- 隠しフィールド（フォーム送信時にエディタの内容を保存） -->
      <%= f.hidden_field :content, id: "hidden_content" %>
    </div>
  
    <!-- 送信ボタン -->
    <div class="actions text-right mt-2">
      <button
        class="px-4 py-2 bg-gray-200 text-gray-500 border border-gray-300 
               rounded-md cursor-not-allowed
               disabled:hover:bg-gray-200 disabled:opacity-50"
        disabled
      >
        🤖AI
      </button>
  
      <button class="hover:bg-yellow-500 px-4 py-2 bg-gray-100 border border-gray-300 text-gray-700 
                     hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 
                     focus:ring-gray-300 rounded-md">
        <%= link_to "📸 手書きを読み取る", camera_path(@user), class: "submit-button text-dark text-decoration-none" %>
      </button>
  
      <%= f.submit "📝 下書き保存", name:"draft", class: "hover:bg-yellow-500 px-4 py-2 bg-gray-200 border border-gray-300 text-gray-800 
                 hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-offset-2 
                 focus:ring-gray-400 rounded-md" %>
  
      <%= f.submit "post", class: "hover:bg-yellow-500 px-4 py-2 bg-gray-200 border border-gray-300 text-gray-800 
                 hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-offset-2 
                 focus:ring-gray-400 rounded-md" %>
    </div>
  <% end %>
  
  <!-- プレースホルダー用のCSS -->
  <style>
    [data-placeholder]:empty::before {
      content: attr(data-placeholder);
      color: #aaa;
      pointer-events: none;
    }
  </style>
  
</div><!--post-->

<!-- JavaScriptの修正 -->
<script>
  document.addEventListener('DOMContentLoaded', function() {
    const boldButton = document.getElementById('bold-button');
    const editor = document.getElementById('editor');
    const hiddenContent = document.getElementById('hidden_content');
    const form = editor.closest('form');
    const charCount = document.getElementById('char-count');
    const MAX_CHARS = 1000;

    // 編集エリアの内容を隠しフィールドに同期
    function syncContent() {
      hiddenContent.value = editor.innerHTML;
    }

    // 文字数をカウントして表示
    function updateCharCount() {
      // innerText を使用してプレーンテキストの文字数を取得
      let text = editor.innerText || "";
      let currentCount = text.length;
      
      // 1000文字を超えている場合の処理
      if (currentCount > MAX_CHARS) {
        charCount.textContent = `${MAX_CHARS} / ${MAX_CHARS}`;
        charCount.classList.add('text-red-500');
        // 超えた場合は追加の文字を削除する
        // 以下のコードはオプションです。ユーザーが1000文字以上入力できないようにします。
        // ただし、HTMLタグを含む場合は適切な処理が必要です。
        editor.innerText = text.substring(0, MAX_CHARS);
        currentCount = MAX_CHARS;
      } else {
        charCount.textContent = `${currentCount} / ${MAX_CHARS}`;
        charCount.classList.remove('text-red-500');
      }
    }

    // ボタンのクリックイベント
    boldButton.addEventListener('click', function(event) {
      event.preventDefault();
      document.execCommand('bold', false, null);
      syncContent();
      updateCharCount();
    });

    // フォーム送信時に内容を同期
    form.addEventListener('submit', function() {
      syncContent();
    });

    // 編集エリアの入力イベント時にも同期（リアルタイム）
    editor.addEventListener('input', function() {
      syncContent();
      updateCharCount();
    });

    // 初期文字数カウントの更新
    updateCharCount();
  });
</script>

```

# tailwind css
## font
font-thin (100)
font-extralight (200)
font-light (300)
font-normal (400)
font-medium (500)
font-semibold (600)
font-bold (700) eaad42
font-extrabold (800)
font-black (900)
## font-size
text-xs	
text-sm	
text-base
text-lg	
text-xl	
text-2xl	
text-3xl	
text-4xl	
text-5xl	
text-6xl		
text-7xl	
text-8xl	
text-9xl

# meta
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- tuboを一時的に無効化 deleteが機能しないから -->
     <%= javascript_include_tag 'application', 'data-turbo-track': 'reload', defer: true %>
     <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
     <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
     <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"></script>
     <%= stylesheet_link_tag "application", media: 'all', "data-turbo-track": "reload" %>
    <!-- これが全てのbootstrapのデザイン(navbar,form)を支えている。↓ -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
     <%= javascript_importmap_tags %> 
     
ユーザーを登録する(gem deviseを使用する)
↓
文字をpostして、
DBに格納して、
それをDBから出して
viewに表示してみる。


- 一日一回投稿したら、次は投稿できなくなる。
- 間違えたら?(まあいっか。あとで)


- deviseでmailログインではなく、名前やxでログインできるようにしてみる。
- x専用でログインさせる
- 投稿できるようにする(now!)
- submitをクリックしたら、というアクションを書く。
よくGPTを読んでから書き始める。
投稿して、submitして、表示するのはいくつかのアクションが重なる。railsではアクションごとに分ける必要があるため、いちいちページをロードする必要がある。その後にajaxとかをやればいい。まずはrailsのルールに則ってやってみる。まずは紙に書いてみる。

submitボタンを押したら投稿されたい。
'entries/new'のページをレンダリングするのではなく、entries/newの中で'form'というファイルをレンダリングして、users/createでも同じようにレンダリングする。

- entries/newの送信フォームボタンをusers/showに表示したい
entries/newでレンダリングして置いておいた_form.html.erbをusers/showにもレンダリングして表示する。


分かりやすくするためにusers/newという風にレンダリングしていく。そしてusers/showでデータを送信すると、ちゃんとレンダリング先のentries/createへ移動するから大丈夫。

- show.html.erbをそのままレンダリングするとエラーになる。だから_showとしてshowにレンダリングして、_showをusersにもレンダリングした。二段階にする理由はentriesの効果を聞かせるためにはentries/showに存在させておく必要があるから。

- 次は、この送信ボタンをレンダリングしてくる必要がある。
entries/newとentries/_newを作る
_newをnewにレンダリングする
users/showに_newをレンダリングする。
↓
デザインをよくする。

#　今
- ✅投稿したやつをXにシェアする機能をつける。
- aboutページを作って日記でもフレーズでもいいよ。youtubeを見つけてあ、このフレーズをいい言葉だなーと思ったらメモしておくとか(実際にdeamon dominiqueの動画のフレーズを動画を貼って説明してみる。歌詞のワンフレーズでも言い方かっこいいなとか思ったら書いていく。自由度高く。
)
- ✅cssが被っているから統一する。show/indexとhome/index。しかもちょっとスタイルが違う。
- 名前でログイン
- ユーザーアイコンを設定する。
- 投稿するvalidationを追加する。(140字以内)





# 収益化
みんなの投稿が見れる。
分からない時とかは、投稿した人のリンクを見れる。
データを分析できる。どれくらい英語が成長したとか。
ユーザーの日記を集めたリストを売る。
英語教材を売る。

# コア
コアがないから、デザインの段階で微妙になる。だからまず何をしたいのか。デザインの前にそこからやってみる。

xでシェアするときにカッコイイデザインにしておくのがポイントかも

# v0
ユーザーログイン機能
投稿できる。
xに投稿できる
# v1以降
文章をメモしておくことができる->有料
広告を省くことができる->有料
みんなの投稿を見ることができる->有料



# deviseでname追加
https://github.com/heartcombo/devise?tab=readme-ov-file#strong-parameters

- Rails 4 moved the parameter sanitization from the model to the controller, causing Devise to handle this concern at the controller as well.

この3つのみがmodelにデータを渡していく。(これにnameを追加すれば良いってことかな??)
sign_in (Devise::SessionsController#create) - Permits only the authentication keys (like email)
sign_up (Devise::RegistrationsController#create) - Permits authentication keys plus password and password_confirmation
account_update (Devise::RegistrationsController#update) - Permits authentication keys plus password, password_confirmation and current_password

でも、めんどくさかったらこうやって書くことができる

#

```ruby
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
  #単純な例(他にも2つあるけど、まあこれでやってみる。)
  devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
　end

end
```


これのemailをnameに変える。その色々な手続きをやる。
# githubに書いてあるやつを、もう一度全部訳してから理解してみる。
# HTTP/cookie(session)
- http: 前にやったことは忘れている。だから安全
- cookie: 覚えるように設定して、無駄な繰り返しを防ぐ。(railsではsessionメソッドがある。)
sessionがあるから、自分がすでにログインしたアカウントに次回もログインせずに使用することができるようになる。
そしてログアウトすると、sessionがdestroyされるような仕組みにする。

#　続き
logout errorになっているからそこを直す。
javascriptをrails7.0.8.6に導入していく。
doc: https://guides.rubyonrails.org/v7.0/
import mapを使って実装していく。(yarnとかwebpack必要ないから。)
↓
どうにもならんから、最初からにして、今まで書いたコードをコピーしてもう一回やっていくことにする。
↓

# 移行する必要があるもの
モデル:

app/models配下のファイル（例: user.rb, post.rbなど）。
コントローラー:

app/controllers配下のファイル（例: users_controller.rb, posts_controller.rbなど）。
APIを使っている場合はapp/controllers/api配下も忘れずに。
ビュー:

app/views配下のテンプレートファイル（例: users/index.html.erb, posts/show.html.erbなど）。
マイグレーションファイル:

db/migrate配下のマイグレーションファイルを新しいプロジェクトにコピー。
設定ファイル:

必要に応じてconfig配下のファイル（例: routes.rb, environmentsフォルダ内の設定ファイルなど）。
アセット（必要な場合）:

app/javascriptやapp/assets配下のJavaScript、CSS、画像ファイル。
Gemfile:

依存するGemを新しいGemfileに移行し、bundle installを実行。

# 移行する手順
dockerfile,ymlを新たなファイルで作る。
そこでrailsアプリを実行する。
↓
全てコピーして移行する。
↓
全てをonedayonelineにすり替えて、ちゃんと起動するか確かめる。


# デプロイ
https://railstutorial.jp/chapters/sign_up?version=4.2#sec-professional_grade_deployment



sessionは必要ないよね?
https://railstutorial.jp/chapters/updating_and_deleting_users?version=4.2#sec-friendly_forwarding
↑
ここから先は飛ばしている。
10/24
# 続き
write->
userpic->userページ->日記、ブクマ
初めての方はこちら->
ブログ->

zennみたいに、右上にlogin&ユーザーアイコンを書いてみる。

#　今
英語"日記"っていう言い方をもっと浸し見やすいもの、かっこいいものに変えればユーザーはもっと食いつくと思う。

英語ジャーナル
デイリースパーク (Daily Spark)
1日の始まりや気づきを英語で表現するイメージ。
Spark Daily
シンプルに「Spark」を前にしてリズミカルな響きに。
Daily Glow
「光」や「輝き」を連想させ、ポジティブな印象。
Word Spark
1日のひらめきを「言葉」にフォーカス。
Little Spark
1日の小さなひらめきを書き留める。
Daily Growth
日々の成長を表現。
Scribble Spark
気軽に落書きのように書く感覚。
Micro Spark
小さなひらめきが毎日積み重なるイメージ。
Spark Journey
小さなひらめきの旅が始まる。
Daily Seed
成長の種を毎日植えるイメージ。
Quick Glow
すぐに取り組める明るい記録。

「小さな言葉が、大きな成長を生む。」
「あなたの成長は、1行から始まる。」
「今日の1行が、明日の自信に。」
「気づけば英語が、あなたの日常に。」
「書くたびに、英語がもっと身近に。」
「英語力は、明日ではなく今日の1行から始まる。」
「未来の自分が感謝する習慣を、今始めよう。」
🔥「言葉にするたび、英語があなたのものになる。」
「1行の種が、大きな木に育つ。」

# どうやってユーザーを毎日自分のアプリに訪れさせるのか。
毎日毎日英語ジャーナルを続けさせるにはどうすればいいのか。
->自分が見本になる。
->ビジュアルで憧れさせる。
->🔥ユーザーを日記を書くことでどうよくなるのか何かで納得させる。(これやろ!自分がそうだから)
->🔥書いたジャーナルの進化を見せる：
AIがユーザーの投稿を読み取って成長を可視化する「あなたの英語力の進化レポート」を定期的に送る。

例：「今週のあなたの英語は、こんなに上達しました！」
英単語のカウント、語彙の広がりなどを可視化。
ビジュアルでのモチベーション：
ユーザーが英語で話している風景の生成に加え、ジャーナル内容をベースにした未来のシーン（例：英語でプレゼンする姿、旅行先で英語を話す自分）をイメージさせる。

# データベースDB無効化有効化
- gemfile
pgコメントアウト
- config/application.rb 
22-26 line
- config/database.yml
1-22 linesコメントアウト


```md
はい、Railsアプリケーションをデータベースを使用せずにデプロイすることは可能です。Railsはデフォルトでデータベースを必要としますが、アプリがデータベースを使用しない場合、以下の手順で設定を変更して対応できます。

Railsアプリをデータベースなしで動作させる方法
1. Gemfile の調整
データベース関連のGemを除去します。

以下のようなデータベース関連のGem（例: pg, sqlite3）をコメントアウトまたは削除します。

ruby
Copy code
# gem 'pg'         # PostgreSQL
# gem 'sqlite3'    # SQLite
Gemfileを更新したら、以下を実行します：

bash
Copy code
bundle install
2. データベースなしでRailsを初期化
Railsのアプリケーション設定でデータベースを無効化します。

config/application.rb の設定を編集：

ruby
Copy code
module YourAppName
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = false  # 必要に応じてAPIモードならtrue
    # データベースを無効化
    config.active_record.migration_error = :app_start # Rails 6以降
    config.active_record.database_selector = false
    config.active_record.legacy_connection_handling = false
  end
end
データベースモジュールを完全に無効化する場合は、以下を追加：

ruby
Copy code
config.generators do |g|
  g.orm :null
end
3. データベース設定を無効化
config/database.yml を削除するか無効化します。Herokuは DATABASE_URL を必要とする場合があるため、削除せず以下のように空の設定にしておくと安全です：

yaml
Copy code
default: &default
  adapter: null

development:
  <<: *default

test:
  <<: *default

production:
  <<: *default
4. Herokuへのデプロイ
Procfileを作成
アプリがデータベースなしで動作するように、Procfile を作成します。

text
Copy code
web: bundle exec rails server -b 0.0.0.0 -p $PORT
デプロイ手順
データベースなしでHerokuにデプロイします：

bash
Copy code
git add .
git commit -m "Deploy Rails app without database"
git push heroku main
Herokuの環境変数確認
DATABASE_URL が設定されている場合は、以下のコマンドで削除します：

bash
Copy code
heroku config:unset DATABASE_URL --app <アプリ名>
5. Railsが正しく動作するか確認
ブラウザでHerokuのURL（例: https://<アプリ名>.herokuapp.com）を開き、Railsアプリが動作していることを確認します。

注意点
データベースが不要な場合でも、一部のGemや機能（例: ActiveRecord）はデータベースに依存しています。それらを使用しないように設計する必要があります。
データベースを完全に無効化するのは基本的に推奨されませんが、静的なアプリや単純なAPIを提供する場合に適しています。
これでRailsアプリをデータベースなしでHerokuにデプロイできます！


I prefer this response
```

# render deploy
- hostブロック。多分render側のキャッシュだと思う。
↓
もう一回作り直すのも手だと思う。
ondayoneline.comのnotionに環境変数を書いておく。それをコピペ。

_micropost.html.erb

```ruby
<div class="diary-container">
        <div class="diary-entries">
            <ul id="entriesList" class="list-group">

            
            <p><%= micropost.content %>
               <%= micropost.created_at %>
               #これを押したら、/microposts.18というrouteへ移動することになる。
               <%= button_to "🗑️", micropost_path(micropost), method: :delete, data: { confirm: "Are you sure?" } %> 
               <p><%= micropost.inspect %></p>
            </p>      

            </ul>
        </div>
</div>
```



# current_userを省いて、friendlyを使う。完成させてからsessionをfriendlyに追加していく。

# 続き
- 手書き認識機能の実装
formでcontrollerに画像を投げる
controllerで処理する。

```ruby
  def analyze
    # formから画像ファイルを受け取る
    uploaded_file = params[:image]

    if uploaded_file.nil?
      flash[:alert] = "画像をアップロードしてください。"
      redirect_to root_path
      return
    end

    # tmpに一時保存
    file_path = Rails.root.join('tmp', uploaded_file.original_filename)
    #開いて、何かを実行している。
    File.open(file_path, 'wb') do |file|
      file.write(uploaded_file.read)
    end

    # OCRを実行
    recognized_text = HandwritingRecognizer.recognize(file_path)

    # 結果を表示
    render json: { text: recognized_text }
  ensure
    # 一時ファイルを削除
    File.delete(file_path) if File.exist?(file_path)
  end
```

problem: 結果が全然違う文字列が出力された。

ruby公式
https://github.com/dannnylo/rtesseract
公式の公式
https://github.com/tesseract-ocr/tesseract


- 処理前に精度を高くしてみる。
 今: rubyにminimagicというimagemagickを取り込むツールが用意されている。(https://github.com/minimagick/minimagick)



-「traineddata」ファイルを取り込んで(学習データ)実行する必要がある。
それでも変わらなかったら、
- 他のORMを探す



home#index.html

```ruby
<div class="text-center" id="nav-section">

<% @microposts.published.each do |micropost| %>
     <div class="diary-container">
        <div class="diary-entries">
            <ul id="entriesList" class="list-group">
          
      
            <div class="all-posts-section">
  <li style="list-style: none; display: flex; justify-content: space-between; align-items: center;">
    <span><strong class=""><%= micropost.user.name %></strong>: <%= micropost.content %></span>
    <span class="text-right text-muted" style="font-size: 0.9em;"><%= micropost.created_at.strftime("%Y/%m/%d") %></span>
  </li>
</div>

    
    </ul>
    </div>
</div>

  <% end %>
</div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

  
```
_micropost_form.html.erb

```ruby
<!--ここでは、@userを意識する必要はない。rendered by users/show -->
<div class="diary-container">
  <div class="diary-entries">

<!-- irb(main):001> app.microposts_path(slug: "a")=> "/a/microposts" -->

<%= form_with(model: @micropost, url: "/#{@user.slug}/microposts", method: :post, local: true, html: { class: "micropost-form" }) do |f| %>
  <!-- 入力フィールド -->
  <div class="field">
    <%= f.text_area :content, 
      placeholder: "i dont think anything is hard. it just takes time.", 
      class: "form-control diary-textarea",
      style: "border: none; box-shadow: none;" %>
  </div>

  <!-- 送信ボタン -->
  <div class="actions text-right">
    <%= f.submit "下書き保存", name:"draft", class: "btn btn-light diary-submit-btn" %>
    <%= link_to "🤖", user_path(@user), class: "btn btn-light submit-button" %>
    <%= f.submit "post", class: "btn btn-light diary-submit-btn" %>
  </div>
<% end %>


  </div>
</div>
```

_micropost.html.erb
```ruby
<% @microposts.published.each do |micropost| %>
  <!-- Twitter Card用のcontent_for(helperメソッド。ここで定義するが、別の場所で利用する場合。) -->
  <% content_for :title, micropost.content.truncate(50) %>
  <% content_for :meta_description, micropost.content.truncate(150) %>
  <% content_for :twitter_image, asset_url("logo01.png") %>

  <!-- 表示部分 -->
  <div class="diary-container">
    <div class="diary-entries">
      <ul id="entriesList" class="list-group">
        <li class="list-group-item">
          <!-- コンテンツ部分 -->
          <p><%= micropost.content %> <span class="text-muted"><%= micropost.created_at.strftime("%Y-%m-%d") %></span></p>
          
       <% if current_user == @user %>
          <!-- 削除ボタン -->
          <%= button_to "🗑️", micropost_path(slug: @user.slug, id: micropost.id), method: :delete, class: "btn btn-sm" %>
          <!-- Xでシェアするボタン -->
          <%= link_to "X",
            "https://twitter.com/intent/tweet?text=#{CGI.escape("✏️ " + micropost.content + "\n")}%0A#{CGI.escape('https://eigopencil.com')}",
            target: "_blank",
            rel: "noopener",
            class: "btn btn-dark text-white btn-sm" %>
        <% end %>
        </li>
      </ul>
    </div>
  </div>
<% end %>
```

# 開発者流eigopencilの使い方

僕がeigopencilを使うときは、日頃英語のコンテンツをブログやkindleなどの文章やYouTubeの動画コンテンツを見たり聞いたりしている時に、「かっこいい言い方だな」「これよく聞くけどどういう意味なんだろう」と疑問に思った時に、そのフレーズを書き留めます。自分なりの文章に変えたいと思った時はそのフレーズや単語の意味を後から見直したときにわかるように記録し、その後オリジナルフレーズを書いておきます。
-- -- -- -- -- -- -- 
kazuma
2024/12/25
原文: My ridiculous intake of over six cups of coffee daily definitely pushed me over the edge, but it was only the catalyst, not the cause.(URL:https://levels.io/reset-your-life/) 

覚える単語/フレーズとその意味: pushed me over the edge: The phrase "pushed me over the edge" typically means that something caused a person to reach their breaking point emotionally, mentally, or in terms of patience. It suggests that the person was already close to their limit, and the event or action pushed them beyond their capacity to cope or remain composed. 

自作英文: coding 8h straight literally pushed me over the edge..

-- -- -- -- -- -- --

そしてそのまま覚えたい時はそのフレーズをそのまま書いて投稿しておきます。
-- -- -- -- -- -- -- 
i dont think anything is hard. it just takes time.
(url: youtube.com/hogehoge)
-- -- -- -- -- -- -- 


僕のテンプレートはここから使う事ができます。
そして、urlを共有することで、英語学習のコンテンツをみんなで共有する事ができます。
もちろん、ユーザーの皆さんの独自のやり方でもできるように、投稿するときはテンプレートを選択する事ができます。


# Hotwire(turbo, stimulus)
- なぜ学ぶ必要があるのか?
ユーザーエクスペリエンスを向上させるためにSPAを実装する。そこでvue,reactを一から学ぶか、hotwireを学ぶか。
## stimulus(https://stimulus.hotwired.dev/)
JSのコードが多くなった時に、controllerで複数のファイルに分けて開発することができる。特定の動作に関連するコードを見つけやすくする。

htmlもclassにdata-*と書いて分けるので、どこにJSの影響が出ているのか見やすくなる。

- 通常
```html
<button id="myButton">クリック</button>
<p id="myText">こんにちは</p>

<script>
  document.getElementById("myButton").addEventListener("click", () => {
    document.getElementById("myText").textContent = "こんにちは、世界！";
  });
</script>

```

- stimulus
railsのバックエンドの処理と似ている。
```html
<div data-controller="example">
  <button data-action="click->example#updateText">クリック</button>
  <p data-example-target="text">こんにちは</p>
</div>

<script>
// app/javascript/controllers/example_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["text"];

  updateText() {
    this.textTarget.textContent = "こんにちは、世界！";
  }
}
</script>
```

stimulusインストール手順
```ruby
gem "stimulus-rails"
```
```ruby: app/javascript/application.js
import "controllers";
```
```shell
rails g stimulus example
```
↓ generated from command above.
```ruby: app/javascript/controllers/example_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus! This is the Example controller.");
  }
}
```
↓registerd atomatically after rails g~ at controller/index.js
```ruby: javascript/controller/index.js
import { application } from "./application";

import ExampleController from "./example_controller";
application.register("example", ExampleController);
```
呼び出す時
```ruby
<div data-controller="example">
  <p>Hello, Stimulus!</p>
</div>
```

portがかぶっていたら、こうやって避けることができる.
bin/devは、Railsに必要な複数のプロセス(Railsサーバー、アセットビルダー、CSSコンパイラーなど)を一括管理するツール。
```shell
PORT=3002 bin/dev
```

## turbo(https://www.hotrails.dev/)<- not official but creater is one of the committer of rails-turbo.

# question
英語を学ぶ理由も、学び方も、人それぞれ異なります。 だからこそ、eigopencilはあなた自身が自由に英語のライティングをアウトプットできるスペースを提供します。

ようこそ
eigopencilは、英語のライティングができるスペースを提供します。

日記や覚えたいフレーズの練習、短い文章、ブログのような長文など、目的やスタイルを問わず、自分らしい英語の表現を磨いていきましょう
- - - 

シンプルで直感的なデザインで、英語日記や覚えたいフレーズを使った自作英文、短い文章、さらにはブログのような長文まで、気軽に書く習慣を始められます。毎日のアウトプットを通じて、英語力を一歩ずつ高めていきましょう。

日記や覚えたいフレーズの練習、短い文章、ブログのような長文など、目的やスタイルを問わず、自分らしい英語の表現を磨いていきましょう


## シンプルなUI/UX
皆さんが、「書く」ことに集中できるように、シンプルなUI/UXを心がけました。
余計なリマインダー、広告などはありません。



# 通常
```ruby
<%= form_with(model: @post, local: true) do |form| %>
  <div class="field">
    <%= form.text_area :content %>
  </div>
<% end %>
```

# quill->隠しフィールドの形にする。
```ruby
<div id="editor">
    <%= f.text_area :content %>
</div>
```

違いは、ユーザーが入力したデータがそのまま送信される場合と、
ユーザーが入力する前後に動的な処理が行われる場合(リッチコンテンツなど)

--

quillの内容をpostボタンを押す前に.contentに格納しておく必要がある。
- リアルタイムで格納
- 送信前に格納

postを押した時に、投稿しますか?はい、いいえと表示し、はいを押したら格納して、データベースに送信するという順番でできるかも。


# quill
javascriptを機能させるために、app/javascript/application.jsの書き方を確かめるorそもそもapplication.jsが必要なのかを確かめつ必要がある。

どこにも載っていないから、とりあえず今は公式を見まくっている。
https://hotwired.dev/
https://railsguides.jp/v7.0/working_with_javascript_in_rails.html#import-maps%E3%81%A8javascript%E3%83%90%E3%83%B3%E3%83%89%E3%83%A9%E3%83%BC%E3%81%AE%E3%81%A9%E3%81%A1%E3%82%89%E3%82%92%E9%81%B8%E3%81%B6%E3%81%8B