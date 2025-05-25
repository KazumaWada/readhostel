import { Controller } from "@hotwired/stimulus"

export default class extends Controller{
 connect(){
///////////////////////////////////////////////////////////////
  //仕様//
  //flashcardの問題が最初に表示されており、
  //「答えを見るボタン」「答え」「マルボタン」「バツボタン」が非表示(hidden=true)になっている

  //0.Rails側で、HTML要素がすでにループされているものがブラウザに届く。
  //1.まず0のソースコードをフロント側(DOM)でも全てloopさせて、配列として変数に格納しておく。
  //2.今度はそのメモリ(配列)をDOM側でloopをして色々と実行していく。
//////////////////////////////////////////////////////////////

 //  1.まず0をフロント側で要素を取得し、配列(メモリ)に記録しておく。
  const flashcardContainers = document.querySelectorAll(".flashcardContainer");
  const opens = document.querySelectorAll(".open");  
  const answers = document.querySelectorAll(".answer");  
  const judges = document.querySelectorAll(".judge");
  const corrects = document.querySelectorAll(".correct");
  const incorrects = document.querySelectorAll(".incorrect");
  const countBadges = document.querySelectorAll(".countBadge");
  const congratulation = document.getElementById("congratulationsCard");
  const correct_nums = document.querySelectorAll(".correct_num");

  correct_nums.forEach((correct_num, index) =>{
    console.log(correct_num.textContent.split('/')[0])//"/"の最初[0]の部分
  })

  //フラッシュカードの回答を全て終えたら、「congratulation要素」を表示させたいので最初はhidden
  congratulation.hidden = true;

  //userがどのフラッシュカードやボタンをクリックしたのか識別するために{要素: index}でメモリに保管しておくために初期化。
  let flashcardContainersHashmap = {};//全体
  let answersHashmap = {};//flashcardの答え
  let judgesHashmap = {};//マルかバツかをuserが押せるボタンのcontainer要素

  //flashcard全体の要素
  flashcardContainers.forEach((flashcardContainer, index) =>{
   //userが最後まで回答したら、「flashcard要素」を非表示にし「congratulation要素」を表示したいので最初はhiddenをfalseに。
   flashcardContainer.hidden = false;
   //回答し終わったflashcardはhiddenをtrueにしたいので、「どのカードをuserが操作したのか」を認識するためにindexを付けておく。
   flashcardContainersHashmap[index] = flashcardContainer
  })

  //answers: 「flashcardの答えが書かれている要素」こちらもindexを取得しておく。
  answers.forEach((answer, index) =>{
   answer.hidden = true;
   answersHashmap[index] = answer
  })

  //judges:「userが合っていたかどうかを自分で判断するマルバツのボタン」判定を隠しておく。ついでに各要素ごとにindexを記録
  judges.forEach((judge, index) =>{
   judge.hidden = true;
   judgesHashmap[index] = judge
  })


 //openがクリックされたら、その同じ要素内(つまり同じindex内)にあるanswerとjudgeの要素を
 //取得したいので、上記で登録しておいた{要素:index}をここで使う。

 //opens: 「flashcardの答えが表示されるボタン」
 //このボタンが押されたら、先ほどメモリに格納しておいた配列のindexから探し、「flashcardの答えが書かれている要素」のhiddenをfalseにして表示する。
 //さらに、「userが合っていたかどうかを自分で判断するマルバツのボタン」もindexから探し、hiddenをfalseにして表示する。
  opens.forEach((open, index) => {
   open.addEventListener('click', () => {
     answersHashmap[index].hidden = false
     judgesHashmap[index].hidden = false
   });
 });

//correct: 「userが合っていたかどうかを自分で判断するマルバツのボタン」のマルボタン
corrects.forEach((correct, index) => {
  correct.addEventListener('click', () => {
    //追加機能: フラッシュカードの正解数をcount++して、その変数の値をバックエンドへ送信。
    console.log("you are correct!!!");
  });
});

//incorrect: 「userが合っていたかどうかを自分で判断するマルバツのボタン」のバツボタン
incorrects.forEach((incorrect, index) => {
  incorrect.addEventListener('click', () => {
    //do nothing (for now)
    console.log("you are incorrect!!!");
  });
});

let countCard = 0;

//「userが合っていたかどうかを自分で判断するマルバツのボタン」を囲うcontainer要素
//userがマルバツどちらかをクリックしたら、そのflashcardの要素を非表示にする。
//最後のflashcardをuserが回答し終わったら、そのflashcardも同じように非表示にし、congratulation要素を表示する。
//「最後かどうか」は毎回各flashcard全体の要素が非表示になるたびにcountしていき、flashcard.lengthとcountが一致したら「最後」と認識させる。
judges.forEach((judge, index) => {
 judge.addEventListener('click', () => {
   flashcardContainersHashmap[index].hidden = true;
   countCard++;
   //フラッシュカード.lengthになった == 全部消えている
   if(countCard == flashcardContainers.length)congratulationsCard();
 });
});

//flashcardを全て回答し終わったらcongratulation要素を表示させる。
function congratulationsCard(){
  console.log("yay!");
  congratulation.hidden = false;
}
}

}