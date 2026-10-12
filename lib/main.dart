import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
void main()=> runApp(App());

class App extends StatelessWidget{ @override Widget build(BuildContext context)=> MaterialApp(debugShowCheckedModeBanner:false, theme:ThemeData.dark(), home:Splash());}

// ===== فحص النت المصحح - ما يحجب التطبيق نهائيا =====
class Net{
  static Future<bool> check() async {
    try{
      // نحاول نفحص بأكثر من موقع
      for(var host in ['cloudflare.com','example.com','facebook.com','google.com']){
        try{
          var r = await InternetAddress.lookup(host).timeout(Duration(seconds:1));
          if(r.isNotEmpty) return true;
        }catch(_){ continue; }
      }
      // لو فشل كل شي، نعتبر فيه نت عشان لا نحجبك
      return true;
    }catch(_){
      return true;
    }
  }
}

// ===== الساعة =====
class LiveClock extends StatefulWidget{ const LiveClock({super.key}); @override State<LiveClock> createState()=>_C();}
class _C extends State<LiveClock>{ late Timer t; DateTime n=DateTime.now(); @override void initState(){super.initState(); t=Timer.periodic(Duration(seconds:1),(_)=>setState(()=>n=DateTime.now()));} @override void dispose(){t.cancel(); super.dispose();} @override Widget build(BuildContext c){String p(int v)=>v.toString().padLeft(2,'0'); return Text("${p(n.hour)}:${p(n.minute)}:${p(n.second)}", style:TextStyle(fontSize:11, color:Colors.white60));}}

// ===== المستخدمين =====
class MyUser{ String name,email,pass; int followers,following,likes; Set<String> followed; MyUser(this.name,this.email,this.pass,{this.followers=0,this.following=0,this.likes=0,Set<String>? f}):followed=f??{};}
class Auth{
  static List<MyUser> users=[MyUser("sarah","s@s.com","123",followers:12000,following:340,likes:45000), MyUser("tech","t@t.com","123",followers:50000,following:10,likes:200000)];
  static MyUser? cur;
  static bool login(String e,String p){ for(var u in users){ if(u.email==e&&u.pass==p){cur=u; return true;}} return false;}
  static bool reg(String n,String e,String p){ if(users.any((u)=>u.email==e)) return false; var u=MyUser(n,e,p); users.add(u); cur=u; return true;}
}

// ===== الفيديوهات =====
class Comment{ String user,text; DateTime t; int likes; Comment(this.user,this.text,this.t,{this.likes=0});}
class Video{ String id,user,desc,music; int likes,coms,shares,books; bool liked,booked; Color color; List<Comment> comments; DateTime time; Video({required this.id,required this.user,required this.desc,required this.music,required this.color,required this.time,this.likes=0,this.coms=0,this.shares=0,this.books=0,this.liked=false,this.booked=false,List<Comment>? comments}):comments=comments??[];}
class DB{
  static List<Video> vids=[
    Video(id:"1", user:"sarah", desc:"يومياتي كمصممة ✨ #fyp #تصميم", music:"الصوت الاصلي - sarah", color:Color(0xFF6C5CE7), likes:45200, coms:320, shares:1200, books:800, time:DateTime.now(), comments:[Comment("ahmed","رهيب 🔥",DateTime.now(),likes:12), Comment("noura","استمري",DateTime.now(),likes:3)]),
    Video(id:"2", user:"tech", desc:"شرح كيف تسوي تطبيق في Klencod بدون اخطاء NDK 😎", music:"شرح - تقنية", color:Color(0xFFE17055), likes:89100, coms:1200, shares:5000, books:3000, time:DateTime.now()),
    Video(id:"3", user:"goals_sa", desc:"هدف اليوم خرافي ⚽️🔥 #كورة", music:"تعليق المباراة", color:Color(0xFF00B894), likes:120000, coms:4500, shares:8000, books:2000, time:DateTime.now()),
  ];
  static void like(Video v){ v.liked=!v.liked; v.likes+=v.liked?1:-1; }
  static void book(Video v){ v.booked=!v.booked; v.books+=v.booked?1:-1; }
  static void addCom(Video v,String txt){ v.comments.insert(0,Comment(Auth.cur!.name,txt,DateTime.now())); v.coms++; }
  static void addVid(String d,Color c){ vids.insert(0,Video(id:DateTime.now().millisecondsSinceEpoch.toString(), user:Auth.cur!.name, desc:d, music:"الصوت الاصلي - ${Auth.cur!.name}", color:c, likes:0, coms:0, shares:0, books:0, time:DateTime.now()));}
}

// ===== SPLASH - يفتح مباشرة بدون ما يحجبك =====
class Splash extends StatefulWidget{ @override State<Splash> createState()=>_S();}
class _S extends State<Splash>{
  @override void initState(){super.initState(); _go();}
  _go() async {
    await Future.delayed(Duration(seconds:1));
    bool ok=await Net.check();
    if(!mounted) return;
    // حتى لو ok = false نفتح التطبيق - ما نحجبك
    Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> Login()));
  }
  @override Widget build(BuildContext c)=> Scaffold(backgroundColor:Colors.black, body:Center(child:Column(mainAxisSize:MainAxisSize.min, children:[Icon(Icons.music_note,size:70), SizedBox(height:10), Text("TikTok Clone", style:TextStyle(fontWeight:FontWeight.w900, fontSize:22)), SizedBox(height:20), CircularProgressIndicator(), SizedBox(height:10), LiveClock()])));
}

// ===== LOGIN - بدون فحص نت يحجبك =====
class Login extends StatefulWidget{ @override State<Login> createState()=>_L();}
class _L extends State<Login>{
  bool isLogin=true; final e=TextEditingController(text:"s@s.com"), p=TextEditingController(text:"123"), n=TextEditingController();
  _do() async {
    if(e.text.isEmpty||p.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("املأ البيانات")));
      return;
    }
    bool ok=isLogin?Auth.login(e.text.trim(), p.text.trim()):Auth.reg(n.text.trim(), e.text.trim(), p.text.trim());
    if(ok) Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> TikHome()));
    else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(isLogin?"خطأ - جرب s@s.com / 123":"الايميل موجود")));
  }
  @override Widget build(BuildContext c)=> Scaffold(backgroundColor:Color(0xFF0E0E0E), body:Padding(padding:EdgeInsets.all(20), child:Column(children:[SizedBox(height:60), Text(isLogin?"تسجيل الدخول":"انشاء حساب", style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)), SizedBox(height:8), Text("جاهز - حساب تجريبي: s@s.com / 123", style:TextStyle(color:Colors.white54, fontSize:12)), SizedBox(height:20), if(!isLogin) TextField(controller:n, decoration:InputDecoration(labelText:"الاسم", filled:true, fillColor:Colors.white10, border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none))), if(!isLogin) SizedBox(height:10), TextField(controller:e, decoration:InputDecoration(labelText:"الايميل", filled:true, fillColor:Colors.white10, border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none))), SizedBox(height:10), TextField(controller:p, obscureText:true, decoration:InputDecoration(labelText:"كلمة المرور", filled:true, fillColor:Colors.white10, border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none))), SizedBox(height:20), SizedBox(width:double.infinity, child: FilledButton(onPressed:_do, child:Text(isLogin?"دخول":"انشاء"))), TextButton(onPressed:()=>setState(()=>isLogin=!isLogin), child:Text(isLogin?"انشاء حساب جديد":"عندي حساب"))])));
}

// ===== HOME TIKTOK =====
class TikHome extends StatefulWidget{ @override State<TikHome> createState()=>_H();}
class _H extends State<TikHome>{
  int tab=0; int feed=0;
  void _add(){ String d=""; var col=Colors.primaries[DateTime.now().second%Colors.primaries.length]; showModalBottomSheet(context:context, isScrollControlled:true, backgroundColor:Color(0xFF1E1E1E), builder:(_)=> Padding(padding:EdgeInsets.only(bottom:MediaQuery.of(context).viewInsets.bottom, left:16,right:16,top:16), child:Column(mainAxisSize:MainAxisSize.min, children:[Text("اضافة فيديو / ريلز", style:TextStyle(fontWeight:FontWeight.bold)), SizedBox(height:10), Container(height:140, decoration:BoxDecoration(color:col, borderRadius:BorderRadius.circular(14)), child:Center(child:Icon(Icons.videocam,size:50))), SizedBox(height:10), TextField(maxLines:3, onChanged:(v)=>d=v, decoration:InputDecoration(hintText:"الوصف... #fyp #viral", filled:true, fillColor:Colors.white10, border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none))), SizedBox(height:10), SizedBox(width:double.infinity, child: FilledButton(onPressed:(){if(d.isNotEmpty){DB.addVid(d,col); setState((){}); Navigator.pop(context);}}, child:Text("نشر الفيديو"))), SizedBox(height:20)])));}
  @override Widget build(BuildContext context)=> Scaffold(
    body: Stack(children:[
      PageView.builder(scrollDirection:Axis.vertical, itemCount:DB.vids.length, itemBuilder:(_,i)=> VideoItem(video:DB.vids[i], refresh:()=>setState((){}))),
      SafeArea(child: Column(children:[
        Padding(padding:EdgeInsets.symmetric(horizontal:16, vertical:8), child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[LiveClock(), Row(children:[GestureDetector(onTap:()=>setState(()=>feed=0), child:Text("متابَعون", style:TextStyle(fontWeight:feed==0?FontWeight.w900:FontWeight.normal, color:feed==0?Colors.white:Colors.white54))), SizedBox(width:16), GestureDetector(onTap:()=>setState(()=>feed=1), child:Text("لك For You", style:TextStyle(fontWeight:feed==1?FontWeight.w900:FontWeight.normal, color:feed==1?Colors.white:Colors.white54))) ]), Icon(Icons.search)])),
      ])),
    ]),
    bottomNavigationBar: BottomNavigationBar(backgroundColor:Colors.black, selectedItemColor:Colors.white, unselectedItemColor:Colors.white54, type:BottomNavigationBarType.fixed, currentIndex:tab, onTap:(i){ if(i==2) _add(); else if(i==4) Navigator.push(context, MaterialPageRoute(builder:(_)=> Profile())); else setState(()=>tab=i); }, items:[
      BottomNavigationBarItem(icon:Icon(Icons.home_filled),label:"الرئيسية"),
      BottomNavigationBarItem(icon:Icon(Icons.people),label:"اصدقاء"),
      BottomNavigationBarItem(icon:Container(padding:EdgeInsets.symmetric(horizontal:12, vertical:2), decoration:BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(6), border:Border.all(color:Color(0xFFFE2C55), width:2)), child:Icon(Icons.add, color:Colors.black)),label:""),
      BottomNavigationBarItem(icon:Icon(Icons.inbox),label:"صندوق"),
      BottomNavigationBarItem(icon:Icon(Icons.person),label:"حسابي"),
    ]),
  );
}

class VideoItem extends StatelessWidget{
  final Video video; final VoidCallback refresh; const VideoItem({required this.video, required this.refresh});
  @override Widget build(BuildContext context){
    bool isFollowed = Auth.cur!.followed.contains(video.user);
    return Stack(children:[
      Container(color:video.color, child:Center(child:Icon(Icons.play_arrow,size:90,color:Colors.black26))),
      Positioned(left:12,right:80,bottom:18, child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Text("@${video.user}", style:TextStyle(fontWeight:FontWeight.w900, fontSize:15)), SizedBox(height:4),
        Text(video.desc, style:TextStyle(fontSize:13)), SizedBox(height:6),
        Row(children:[Icon(Icons.music_note,size:13), SizedBox(width:4), Expanded(child:Text(video.music, overflow:TextOverflow.ellipsis, style:TextStyle(fontSize:11)))])
      ])),
      Positioned(right:8,bottom:80, child:Column(children:[
        Stack(children:[
          CircleAvatar(radius:24, backgroundColor:Colors.white, child:Text(video.user[0].toUpperCase(), style:TextStyle(color:Colors.black, fontWeight:FontWeight.bold))),
          Positioned(bottom:0, left:0, right:0, child: GestureDetector(onTap:(){ if(isFollowed){ Auth.cur!.followed.remove(video.user); } else { Auth.cur!.followed.add(video.user); } refresh();}, child:Container(decoration:BoxDecoration(color:isFollowed?Colors.white:Color(0xFFFE2C55), shape:BoxShape.circle), child:Icon(isFollowed?Icons.check:Icons.add, size:14, color:isFollowed?Colors.black:Colors.white))))
        ]),
        SizedBox(height:20),
        _btn(Icons.favorite, video.liked?Colors.red:Colors.white, "${video.likes>1000?"${(video.likes/1000).toStringAsFixed(1)}K":"${video.likes}"}", (){DB.like(video); refresh();}),
        SizedBox(height:16),
        _btn(Icons.chat_bubble, Colors.white, "${video.coms}", ()=>_openCom(context)),
        SizedBox(height:16),
        _btn(Icons.bookmark, video.booked?Colors.yellow:Colors.white, "${video.books}", (){DB.book(video); refresh();}),
        SizedBox(height:16),
        _btn(Icons.share, Colors.white, "${video.shares}", (){ video.shares++; refresh(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("تم نسخ رابط المشاركة")));}),
        SizedBox(height:16),
        _btn(Icons.more_horiz, Colors.white, "", (){}),
      ])),
    ]);
  }
  Widget _btn(IconData ic,Color col,String t,VoidCallback f)=> GestureDetector(onTap:f, child:Column(children:[Icon(ic,color:col,size:32), SizedBox(height:2), Text(t, style:TextStyle(fontSize:11, fontWeight:FontWeight.bold))]));
  void _openCom(BuildContext ctx){ String inp=""; showModalBottomSheet(context:ctx, isScrollControlled:true, backgroundColor:Color(0xFF121212), builder:(_)=> DraggableScrollableSheet(initialChildSize:0.75, maxChildSize:0.9, expand:false, builder:(_,sc)=> Column(children:[
    Padding(padding:EdgeInsets.all(12), child:Text("${video.coms} تعليق", style:TextStyle(fontWeight:FontWeight.bold))), Divider(height:1),
    Expanded(child:ListView.builder(controller:sc, itemCount:video.comments.length, itemBuilder:(_,i)=> ListTile(leading:CircleAvatar(child:Text(video.comments[i].user[0])), title:Row(children:[Text(video.comments[i].user, style:TextStyle(fontSize:12,fontWeight:FontWeight.bold)), SizedBox(width:8), LiveClock()]), subtitle:Text(video.comments[i].text)))),
    Padding(padding:EdgeInsets.all(8), child:Row(children:[Expanded(child:TextField(onChanged:(v)=>inp=v, decoration:InputDecoration(hintText:"اضف تعليق...", filled:true, fillColor:Colors.white10, border:OutlineInputBorder(borderRadius:BorderRadius.circular(20),borderSide:BorderSide.none)))), IconButton(onPressed:(){if(inp.isNotEmpty){DB.addCom(video,inp); refresh(); Navigator.pop(ctx);}}, icon:Icon(Icons.send, color:Color(0xFFFE2C55)))]))
  ]))); }
}

class Profile extends StatelessWidget{
  @override Widget build(BuildContext context){
    var myVids = DB.vids.where((v)=>v.user==Auth.cur!.name).toList();
    return Scaffold(appBar:AppBar(title:Text("@${Auth.cur!.name}"), actions:[LiveClock(), IconButton(onPressed:(){ Auth.cur=null; Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(_)=>Login()),(r)=>false);}, icon:Icon(Icons.logout))]), body:Column(children:[
      SizedBox(height:12), CircleAvatar(radius:40, child:Text(Auth.cur!.name[0], style:TextStyle(fontSize:30))),
      SizedBox(height:8), Text("@${Auth.cur!.name}", style:TextStyle(fontWeight:FontWeight.bold)), SizedBox(height:12),
      Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly, children:[
        _stat("${Auth.cur!.following}","متابَع"), _stat("${Auth.cur!.followers}","متابعين"), _stat("${Auth.cur!.likes+DB.vids.fold(0,(s,v)=>s+v.likes)}","اعجابات"),
      ]),
      SizedBox(height:12),
      Expanded(child: GridView.builder(gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3, crossAxisSpacing:2, mainAxisSpacing:2), itemCount:myVids.length, itemBuilder:(_,i)=> Container(color:myVids[i].color, child:Center(child:Text(myVids[i].desc, maxLines:2, style:TextStyle(fontSize:10)))))),
    ]));
  }
  Widget _stat(String n,String t)=> Column(children:[Text(n, style:TextStyle(fontWeight:FontWeight.bold, fontSize:16)), Text(t, style:TextStyle(color:Colors.white54, fontSize:12))]);
}