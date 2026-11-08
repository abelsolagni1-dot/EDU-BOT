const $ = (id) => document.getElementById(id);
let token = localStorage.getItem("edubot_token") || "";
let profile = null;
let role = "etudiant";
const msg = (s) => { $("toast").textContent=s; $("toast").style.display="block"; setTimeout(()=>$("toast").style.display="none",3500); };
async function api(path, options={}) {
  const headers = {...(options.headers||{})};
  if(token) headers.Authorization = `Bearer ${token}`;
  if(options.body) headers["Content-Type"]="application/json";
  const res=await fetch(path,{...options,headers});
  const data=await res.json().catch(()=>({}));
  if(!res.ok) throw new Error(data.detail || data.message || "Une erreur est survenue");
  return data;
}
function showAuth(){ $("auth").classList.remove("hidden"); $("dashboard").classList.add("hidden"); $("logout").classList.add("hidden"); }
function showDashboard(){ $("auth").classList.add("hidden"); $("dashboard").classList.remove("hidden"); $("logout").classList.remove("hidden"); }
document.querySelectorAll(".tab").forEach(b=>b.onclick=()=>{
 document.querySelectorAll(".tab").forEach(x=>x.classList.remove("active"));b.classList.add("active");
 $("loginForm").classList.toggle("hidden",b.dataset.tab!=="login");$("signupForm").classList.toggle("hidden",b.dataset.tab!=="signup");$("authMessage").textContent="";
});
$("loginForm").onsubmit=async e=>{e.preventDefault();try{const d=await api("/api/auth/login",{method:"POST",body:JSON.stringify({email:$("loginEmail").value,password:$("loginPassword").value})});token=d.access_token;localStorage.setItem("edubot_token",token);await loadApp();}catch(err){$("authMessage").textContent=err.message;}};
$("signupForm").onsubmit=async e=>{e.preventDefault();try{const d=await api("/api/auth/signup",{method:"POST",body:JSON.stringify({email:$("email").value,password:$("password").value,nom_complet:$("name").value,filiere:$("filiere").value,niveau:$("niveau").value,langue:$("language").value})});$("authMessage").textContent=d.message+" Connecte-toi après confirmation de ton e-mail."; }catch(err){$("authMessage").textContent=err.message;}};
$("logout").onclick=async()=>{try{await api("/api/auth/logout",{method:"POST"});}catch(e){}token="";localStorage.removeItem("edubot_token");showAuth();};
async function loadApp(){
 try{
  const me=await api("/api/me");profile=me.profile;role=me.role;
  if(!profile) throw new Error("Profil introuvable. Vérifie que le script SQL a été exécuté.");
  showDashboard();
  const name=profile.nom_complet||"étudiant";$("welcomeTitle").textContent=`Bienvenue, ${name}`;
  $("profileLine").textContent=`${profile.filieres?.nom||""} · ${profile.niveau||""}`;
  $("statFiliere").textContent=profile.filieres?.nom||"—";$("statNiveau").textContent=profile.niveau||"—";
  await Promise.all([loadCourses(),loadExercises(),loadExams(),loadProgress()]);
  if(role==="admin"){ $("adminNav").classList.remove("hidden"); loadAdmin(); } else { $("adminNav").classList.add("hidden"); }
 }catch(err){msg(err.message);token="";localStorage.removeItem("edubot_token");showAuth();}
}
function card(title,body,small="",button=null){const el=document.createElement("article");el.className="resource";const h=document.createElement("h3");h.textContent=title;el.append(h);const s=document.createElement("small");s.textContent=small;el.append(s);const p=document.createElement("p");p.textContent=body;el.append(p);if(button)el.append(button);return el;}
async function loadCourses(){try{const a=await api("/api/courses");$("coursesList").replaceChildren(...a.map(x=>{const b=document.createElement("button");b.className="primary";b.textContent="Marquer comme terminé";b.onclick=async()=>{try{await api(`/api/progress/${x.id}`,{method:"POST"});msg("Progression enregistrée");loadProgress();}catch(e){msg(e.message)}};return card(x.titre,x.contenu,x.matieres?.nom||"Cours",b)}));$("statResources").textContent=a.length;}catch(e){msg(e.message)}}
async function loadExercises(){try{const a=await api("/api/exercises");$("exercisesList").replaceChildren(...a.map(x=>{const b=document.createElement("button");b.className="ghost";b.textContent="Afficher le corrigé";b.onclick=()=>alert(x.correction||"Correction non disponible");return card(x.titre,x.enonce,x.matieres?.nom||"Exercice",b)}));}catch(e){msg(e.message)}}
async function loadExams(){
 try{
  const exams=await api("/api/exams");
  $("examsList").replaceChildren(...exams.map(ex=>{
    const box=document.createElement("article");box.className="resource";
    const h=document.createElement("h3");h.textContent=ex.titre;box.append(h);
    const sm=document.createElement("small");sm.textContent=`${ex.matieres?.nom||"Matière"} · ${ex.duree_minutes} minutes · ${ex.questions.length} question(s)`;box.append(sm);
    const btn=document.createElement("button");btn.className="primary";btn.textContent="Commencer l'examen";
    btn.onclick=()=>runExam(ex);box.append(btn);return box;
  }));
 }catch(e){msg(e.message)}
}
async function runExam(ex){
 try{
  const start=await api(`/api/exams/${ex.id}/start`,{method:"POST"});
  const attemptId=start.attempt_id;
  const deadline=Date.now()+Number(start.duration_minutes)*60000;
  const area=document.createElement("div");area.className="resource";
  const title=document.createElement("h3");title.textContent=ex.titre;area.append(title);
  const timer=document.createElement("p");timer.className="eyebrow";area.append(timer);
  const form=document.createElement("form");
  const chosen={};
  ex.questions.forEach((q,i)=>{
    const field=document.createElement("fieldset");field.style.cssText="border:1px solid #e2e8f0;border-radius:10px;margin:14px 0;padding:12px";
    const legend=document.createElement("legend");legend.textContent=`${i+1}. ${q.enonce} (${q.points} pt)`;field.append(legend);
    q.options_questions.forEach((opt,j)=>{
      const label=document.createElement("label");label.style.cssText="display:flex;gap:8px;align-items:center;font-weight:400";
      const radio=document.createElement("input");radio.type="radio";radio.name=q.id;radio.value=opt.id;radio.style.width="auto";
      radio.onchange=()=>chosen[q.id]=opt.id;
      label.append(radio,document.createTextNode(opt.texte));field.append(label);
    });form.append(field);
  });
  const submit=document.createElement("button");submit.className="primary";submit.textContent="Soumettre mes réponses";form.append(submit);
  form.onsubmit=async ev=>{
    ev.preventDefault();submit.disabled=true;
    try{
      const answers=Object.entries(chosen).map(([question_id,option_id])=>({question_id,option_id}));
      const result=await api("/api/exams/submit",{method:"POST",body:JSON.stringify({attempt_id:attemptId,answers})});
      area.replaceChildren();
      const h=document.createElement("h3");h.textContent="Examen terminé";area.append(h);
      const p=document.createElement("p");p.textContent=`Ton résultat : ${result.score}/20`;area.append(p);
      const note=document.createElement("p");note.textContent="Le résultat est enregistré dans ta progression.";area.append(note);
      loadProgress();
    }catch(err){msg(err.message);submit.disabled=false;}
  };
  area.append(form);
  $("examsList").prepend(area);
  const tick=()=>{const left=Math.max(0,deadline-Date.now());const min=Math.floor(left/60000),sec=Math.floor((left%60000)/1000);timer.textContent=`Temps restant : ${min}:${String(sec).padStart(2,"0")}`;if(left<=0){timer.textContent="Temps écoulé. La soumission doit être effectuée immédiatement.";}}
  tick();const clock=setInterval(()=>{tick();if(Date.now()>=deadline)clearInterval(clock);},1000);
  area.scrollIntoView({behavior:"smooth",block:"start"});
 }catch(e){msg(e.message)}
}
async function loadProgress(){try{const d=await api("/api/progress");const r=d.resume||{};$("myCoursesDone").textContent=`${r.cours_termines||0} / ${r.cours_total||0}`;$("myExamsDone").textContent=r.examens_realises||0;$("myExamAverage").textContent=r.moyenne_examens==null?"—":`${r.moyenne_examens}/20`;const all=[...(d.cours||[]).map(x=>card(x.cours?.titre||"Cours",x.termine?"Terminé":"En cours","Progression")), ...(d.examens||[]).map(x=>card(x.examens?.titre||"Examen",x.note==null?"Pas encore noté":`Note : ${x.note}/20`,`${x.statut} · ${x.debut?new Date(x.debut).toLocaleDateString():""}`))];$("progressList").replaceChildren(...all); }catch(e){msg(e.message)}}
document.querySelectorAll(".navbtn").forEach(b=>b.onclick=()=>{document.querySelectorAll(".navbtn").forEach(x=>x.classList.remove("active"));b.classList.add("active");document.querySelectorAll(".page").forEach(x=>x.classList.add("hidden"));$(`page-${b.dataset.page}`).classList.remove("hidden");});
$("chatForm").onsubmit=async e=>{e.preventDefault();const q=$("question").value.trim();if(!q)return;const hist=$("chatHistory");const u=document.createElement("div");u.className="userbubble";u.textContent=q;hist.append(u);$("question").value="";const wait=document.createElement("div");wait.className="botbubble";wait.textContent="EDU-BOT réfléchit…";hist.append(wait);hist.scrollTop=hist.scrollHeight;try{const d=await api("/api/chat",{method:"POST",body:JSON.stringify({question:q})});wait.textContent=d.answer||"Je n'ai pas de réponse.";if(d.sources?.length){const src=document.createElement("small");src.className="source-list";src.textContent="Cours consultés : "+d.sources.map(x=>`${x.matiere||"Matière"} — ${x.titre}`).join(" ; ");wait.append(src);}else{const src=document.createElement("small");src.className="source-list";src.textContent="Aucun cours correspondant trouvé dans ton programme.";wait.append(src);}}catch(err){wait.textContent=err.message;}hist.scrollTop=hist.scrollHeight;};

async function loadAdmin(){
 try{
  const [overview,subjects,students,exams,filieres,results]=await Promise.all([
   api("/api/admin/overview"),api("/api/admin/subjects"),api("/api/admin/students"),api("/api/admin/exams"),api("/api/admin/filieres"),api("/api/admin/results")
  ]);
  $("adminStudentsCount").textContent=overview.students;
  $("adminExamsDone").textContent=results.examens_termines;
  $("adminExamsGraded").textContent=results.examens_notes;
  $("adminExamAverage").textContent=results.moyenne_generale==null?"—":`${results.moyenne_generale}/20`;
  $("adminResultsList").replaceChildren(...results.tentatives.map(x=>card(
   x.etudiants?.nom_complet||"Étudiant",
   x.note==null?"Non noté":`Note : ${x.note}/20`,
   `${x.examens?.titre||"Examen"} · ${x.etudiants?.filieres?.nom||""} · ${x.etudiants?.niveau||""} · ${x.statut}`
  )));
  $("adminCoursesCount").textContent=overview.courses;
  $("adminExamsCount").textContent=overview.exams;
  const fill=(id)=>$(id).replaceChildren(...subjects.map(s=>{const o=document.createElement("option");o.value=s.id;o.textContent=`${s.nom} · ${s.niveau} · ${s.filieres?.nom||""}`;return o;}));
  $("subjectFiliere").replaceChildren(...filieres.map(f=>{const o=document.createElement("option");o.value=f.id;o.textContent=f.nom;return o;}));
  ["courseSubject","exerciseSubject","examSubject"].forEach(fill);
  $("adminStudentList").replaceChildren(...students.map(s=>card(s.nom_complet||"Étudiant",s.niveau,`${s.filieres?.nom||""} · ${s.langue||"fr"}`)));
  $("adminExamList").replaceChildren(...exams.map(x=>{
   const b=document.createElement("button");b.className=x.publie?"ghost":"primary";b.textContent=x.publie?"Dépublier":"Publier";
   b.onclick=async()=>{try{await api(`/api/admin/exams/${x.id}/publish?publie=${!x.publie}`,{method:"PATCH"});msg("Statut de publication mis à jour");loadAdmin();loadExams();}catch(e){msg(e.message)}};
   return card(x.titre,`${x.duree_minutes} minutes`,`${x.matieres?.nom||"Matière"} · ${x.publie?"Publié":"Brouillon"}`,b);
  }));
 }catch(e){msg("Administration : "+e.message);}
}
$("adminSubjectForm").onsubmit=async e=>{
 e.preventDefault();
 try{
  await api("/api/admin/subjects",{method:"POST",body:JSON.stringify({
   filiere_id:$("subjectFiliere").value,niveau:$("subjectLevel").value,
   nom:$("subjectName").value,description:$("subjectDescription").value
  })});
  msg("Matière enregistrée");e.target.reset();loadAdmin();
 }catch(err){msg(err.message);}
};
$("adminCourseForm").onsubmit=async e=>{e.preventDefault();try{await api("/api/admin/courses",{method:"POST",body:JSON.stringify({matiere_id:$("courseSubject").value,titre:$("courseTitle").value,contenu:$("courseContent").value,publie:$("coursePublish").checked})});msg("Cours enregistré");e.target.reset();loadAdmin();loadCourses();}catch(err){msg(err.message)}};
$("adminExerciseForm").onsubmit=async e=>{e.preventDefault();try{await api("/api/admin/exercises",{method:"POST",body:JSON.stringify({matiere_id:$("exerciseSubject").value,titre:$("exerciseTitle").value,enonce:$("exercisePrompt").value,correction:$("exerciseCorrection").value,publie:$("exercisePublish").checked})});msg("Exercice enregistré");e.target.reset();loadAdmin();loadExercises();}catch(err){msg(err.message)}};
$("adminExamForm").onsubmit=async e=>{
 e.preventDefault();
 try{
  const lines=$("examQuestions").value.split("\n").map(x=>x.trim()).filter(Boolean);
  const questions=lines.map((line,i)=>{
   const p=line.split("|").map(x=>x.trim());
   if(p.length<3)throw new Error(`Ligne ${i+1} : utilise Énoncé | option 1 ; option 2 | numéro de la bonne option | explication`);
   const options=p[1].split(";").map(x=>x.trim()).filter(Boolean);
   const correct=Number(p[2])-1;
   if(!Number.isInteger(correct)||correct<0||correct>=options.length)throw new Error(`Ligne ${i+1} : numéro de bonne option invalide`);
   return {enonce:p[0],options,correct_option_index:correct,explication:p.slice(3).join(" | "),points:1};
  });
  await api("/api/admin/exams",{method:"POST",body:JSON.stringify({matiere_id:$("examSubject").value,titre:$("examTitle").value,duree_minutes:Number($("examDuration").value),publie:false,questions})});
  msg("Examen créé en brouillon");e.target.reset();loadAdmin();
 }catch(err){msg(err.message);}
};

if(token)loadApp();else showAuth();
    
