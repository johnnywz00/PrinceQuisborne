#charset "us-ascii"
#include "princeq.h"

// #include <dynfunc.h>
// #include <dynfunc.t>
// #include <reflect.h>
// #include <reflect.t>

//////////      F U N C T I O N S   //////////////////

//	local f = File.openTextFile('princeq.h', FileAccessReadWriteKeep);
//	local g = f.readFile(); 

execStr(str,suspCmdSep?) { 
	if(!str) return; 
	local toks = Tokenizer.tokenize(str);
	if(suspCmdSep) cmdSepTransform.active = true;
	try executeCommand(gPlayerChar, gPlayerChar, toks, true);
	finally cmdSepTransform.active = nil; }

Int(val) { return toInteger(val); }
Str(val) { return toString(val); }
Num(val) { return toNumber(val); }

// Lst(vec, start=1, count=len(vec) ) { return vec.toList(start, count); }  //errors w default arguments
Lst(vec) { return vec.toList(); } 

len(val) { if(!val) return nil; 
	local arg = dataType(val); 
	if(arg not in (TypeSString, TypeList) && 
			!val.oK(Vector) && !val.oK(StringBuffer) && !val.oK(LookupTable)) {
		"Error: Incorrect argument type\n"; 
		return nil; }
	else if(!val.oK(LookupTable)) return val.length();
	else return val.getEntryCount(); }

dobjWords(str) {
	if(gAction && gDobj && gAction.getDobjWords && gAction.getDobjWords.iO(str)) return true;
	return nil;
}
	// could change metric to use the adjective if n is greater than a certain amount
meas(int, denom, adj?) { local ret; 
	if(mStd) ret = (adj ? adj + ' ' : '') + spellInt(int) + ' ' + denom;
	else { switch(denom) { case 'inches': case inches: ret = roundMeas(int * 2.54,true) + '  centimeters'; break; 
		case 'feet': case feet: 
			local met = int * 0.3048;
			local rd = roundMeas(met);
			ret = (int > 50 ? spellInt(Int(met)) : rd) + ' meter<<if !rd.find(R'one$')>>s'; break;
		case 'yards': case yards: ret = spellInt(Int(int * 0.914)) + ' meters'; break; 
		case 'miles': case miles: ret = roundMeas(int * 1.609) + ' kilometers'; break;
		} } return ret; } 
roundMeas(n,inch?) { local nw = toInteger(n.getWhole()); 
	local whole = spellInt(nw); 
	local frac = n.getFraction(); 
	if(frac < .2) return whole; 
	else if(frac < .33) return 'a little over ' + whole;
	else if(frac < .66) return rand('about ','around ') + whole + (inch ? '':' and a half');
	else if(frac < .8) return 'a little under <<spellInt(nw + 1)>>';
	else return spellInt(nw + 1); 
	} 
enum standard, metric ; 
enum feet, yards, inches, miles; 
	
printWeekday(daynum) { switch(daynum) {
	case 1: return 'Sunday';
	case 2: return 'Monday';
	case 3: return 'Tuesday';
	case 4: return 'Wednesday';
	case 5: return 'Thursday';
	case 6: return 'Friday';
	case 7: return 'Saturday';
	default: return nil;
	} }
	
typeOut(str,delay = 20,force?) { 
	if(libGlobal.typeOutOn || force) {
		local was = (gTranscript ? gTranscript.isActive : nil); 
		if(gTranscript) { gTOff; } 
		local lgt = str.length; 
		for(local i in 1..lgt) { 
			"<<str.substr(i,1)>>"; 
			timeDelay(delay); } 
		if(gTranscript) gTranscript.isActive = was; }
	else "<<str>>"; }

binConv(x) {local vec = new Vector(15); if (x>1) 
		{ while (x >= 2) {vec.prepend(x % 2); x /= 2; }
		vec.prepend(1); 
		return vec.join; }
	else if (x==1) return 1; 
	else return 0; }

addBinary(val1,val2) { 
	local a = new Vector(val1.split()); 
	local b = new Vector(val2.split()); 
	local c = new Vector(16); 
	local carry = nil; 
	for(local i = 15; i >= 1; i -=2) { 
		local wasCarry = carry; local ax = a[i];
		if(carry) { 
				if(a[i]=='1') a[i] = '0'; 
				else { a[i] = '1'; carry = nil; } }
		if(a[i]!=b[i]) c.prepend('1');
		else { c.prepend('0'); 
			if(wasCarry && ax=='1'||wasCarry && b[i]=='1'||b[i]=='1'&& ax=='1') carry = true; 
			else carry = nil; }		}
	if(carry) c.prepend('1'); 
	else c.prepend('0'); 
	return c.join(' '); }

qGraphics() { return systemInfo(SysInfoInterpClass) == SysInfoIClassHTML && systemInfo(SysInfoPrefImages); }
qSounds() { return systemInfo(SysInfoInterpClass) == SysInfoIClassHTML && systemInfo(SysInfoPrefSounds); }
terpWarning() { if(systemInfo(SysInfoInterpClass) != SysInfoIClassHTML && !glob.srMode) 
	"\b\ \ <font size=+1>[ ATTENTION:</font> We divine that you are running this game on an interpreter with limitations. If you run this game instead through a program such as QTads by Nikos Chantziaras, you will have an inventory sidebar, a few graphically-represented puzzles, and a few sounds. The current interpreter, in addition to lacking these features, may also cause unsightly spacing or layout issues in the text, and the instructions and hints menus may behave erratically. ,,,As of this writing the newest version of QTads was 3.3, and was available at https://github.com/realnc/qtads/releases/tag/v3.3.0 ]"; }
	    		
fauxWin(str1,str2) { if(!gR('fauxwin')) {
		if(!fastness.seen) { return '<<str1>>, you are suddenly transported to that sought-after destination, the Fastness of the Dracken Fells! You didn\'t even have to journey to find it! It is certainly a good thing you thought to <<str2>>. Hold on, we\'re... oh. As you were: no Fastness. Still in the same place where you had the idea to <<str2>>. <.tr fauxwin400>'; }
		else if(!bean.seen) { return '<<str1>>, the magical bean appears in your very hands! You didn\'t even have to journey to find it! It is certainly a good thing you thought to <<str2>>. Hold on, we\'re... oh. As you were: no bean. Still all the same inventory you had when you got the idea to <<str2>>. <.tr fauxwin400>'; }
		else { return '<<str1>>, you are suddenly whisked away to the very location spoken of by the Phantom -- the Mystic Vale, the very planting-spot for the magical bean! You didn\'t even have to journey to find it! It is certainly a good thing you thought to <<str2>>. Hold on, we\'re... oh. As you were: no Mystic Vale. Still in the same place where you had the idea to <<str2>>. <.tr fauxwin400>'; } }
	return nil;  }

DefineAction(Walkthrough,FileOpAction)
	filePromptMsg = 'Please it you to select a name for your walkthrough file'
    fileTypeID = FileTypeText
    fileDisposition = InFileSave
	execSystemAction { execWalkthrough(true); }
	performFileOp(fname, ack) {
		local f = File.openTextFile(fname,FileAccessWrite); 
		local o = walkthroughObj;
		local ct = 1;
		local func = function(a){ return toString(ct++)+'. \t'+a; };
		f.writeFile((o.txt+o.txt2).findReplace('>',func));
		f.writeFile((o.txt3+o.txt4).findReplace('>',func)); 
		f.closeFile(); }	;
vR(Walkthrough) 'walkthrough'|'walkthru' : WalkthroughAction ;

execWalkthrough(useMsg?) { showMenuWOInv(walkthroughMenu); if(useMsg) "You return from your thoughts. "; }

walkthroughMenu: MenuItem '<tt>\ &lt;&gt; Walkthrough\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ &lt;&gt; </tt>\b' heading = '\ \ WALKTHROUGH'
	location = instrMenu
	menuOrder = 1005 ;
+ MenuLongTopicItem 'Save as a file\b' 
	showMenuCommon(a) { WalkthroughAction.setUpFileOp(true); return M_QUIT; } ;

+ MenuItem 'Read walkthrough now\b' ;
++ MenuLongTopicItem '\ - Part 1 \b'
	isChapterMenu = true
	menuContents { say(walkthroughObj.txt); } ;
++ MenuLongTopicItem '\ - Part 2 \b'
	isChapterMenu = true
	menuContents { "[previous command was \"nw\", putting us in the chessboard hall]\b";
		say(walkthroughObj.txt2); } ;
++ MenuLongTopicItem '\ - Part 3 \b'
	isChapterMenu = true
	menuContents { "[previous command was \"take glove\", behind the tannery]\b";
		say(walkthroughObj.txt3); } ;
++ MenuLongTopicItem '\ - Part 4 \b'
	isChapterMenu = true
	menuContents { "[previous command was \"hook paper with pole\", at the privy]\b";
		say(walkthroughObj.txt4); } ;

remember() { rememberMenu.display; "You return from your thoughts. "; }

rememberMenu: MenuItem '\ \ \ REMEMBERING' ;
+ MenuLongTopicItem '\ - GOALS \b' heading = '\ - GOALS \b'
	menuContents {
		if(!baileyLoc.seen) "Following the prince where he's leading you is your first objective. ";
		else if(!festival.seen) "Getting King Phisbeer\'s rutabagas to the Great Festival is your first mission. ";
		else if(!gR('firstlightbox')) "You really want to get your ember box lit again, before embarking on any serious adventuring. ";
		else if(!gR('triedIceOnFoot')) "Lord Zendarc mentioned a fastness in the North which may harbor secrets pertaining to the crown\'s whereabouts. Trying to find the fastness is the only thing you have to go on as of yet. ";
		else if(!fastness.seen) "You need to find that fastness, so you\'ll have to find a way to get north of the frozen lake. ";
		else if(!organ.seen) "You\'ll have to investigate the fastness thoroughly to find where its secrets are harbored. ";
		else if(!phantom.seen) "You have searched the fastness thoroughly enough, but you still need to figure out how to reveal its secrets. ";
		else {
			local req = [0,0,0];
			if(!sl12.seen) "According to the Phantom, it sounds like you need to find the Monks of Mowm. \b";
			else if(!monCourt.seen) "The Phantom directed you to the Monks of Mowm. You\'ve got to get into the monastery to see what comes of it. \b";
			else if(!gR('dirsToUz')) "The Phantom said that you needed to acquire a magic bean. It directed you to the Monks of Mowm. \b";
			else if(!harbor.seen) "It sounds like your only reasonable chance of finding a magic bean is to visit the island of Uzumbung that Yimnaru spoke of. \b"; 
			else if(!utlu.seen) "You\'ve been to Uzumbung, but you haven\'t found the wild people that Yimnaru spoke of who may have a magic bean in their possession. \b";
			else if(!gR('beangiven')) "Ultimately, you need to see if you can get a magic bean from the Tuttarumbish. \b";
			else ++req[1];

			if(!flagsHi.described) "According to the Phantom, before you travel to the Regions of Eternal Night you will need to learn the directions you must follow through them once you are there. \b";
			else ++req[2];

			if(!gR('madeCompass')) "The Phantom has said that you will need to come up with a way to tell what direction you are traveling in, or else you will never be able to make it through the Regions of Eternal Night. \b";
			else ++req[3];

			if(req[1]&&req[2]&&req[3]) "As long as you have a magic bean, knowledge of the way through the Regions of Eternal Night, and a means to discern which direction you\'re traveling in, then... you need to go and plant the bean in the Mystic Vale! ";
		}
	} ;
+ MenuLongTopicItem '\ - King Phisbeer\'s visit \b' heading = '\ - King Phisbeer\'s visit \b'
	menuContents { "King Phisbeer the Paranoid had sought you out to speak of taking his son under your guidance. <<textObj.phisVisit>>\b\ \ \ \ \ \ The interview had closed with his urgently entreating you to take the lad under your wing, to make a man and a leader of him while there was still time. You accepted with a good will... "; } ;

rememberZen: MenuLongTopicItem '\ - Lord Zendarc\'s challenge \b' heading = '\ - Lord Zendarc\'s challenge \b'
	menuContents { "You think back to that night at the Festival, when Lord Zendarc was speaking to Quisborne... \b\ \ \ \ \ \ \"<<textObj.zenChallenge>>\b\ \ \ \ \ \ \"Quisborne, you show me that you're worthy to find and bring back the ancient crown of <<realm>>, and your request for the hand of my daughter will be duly considered. Is there really such a crown? Not my problem! What say you? In the meantime, don't try my patience by showing me your face again. Consider yourself fairly treated!\" "; } ;
rememberPhantom: MenuItem '\ - The Phantom of the Dracken Fells \b' heading = ''
;
+ MenuLongTopicItem '<font size=+1><tt><i>\ \ \ &lt;=o=&gt;\ \ The Phantom\'s speech (6-7 min)\ \ &lt;=o=&gt;\ </i></tt></font>\b\b'
	heading = '\ - The Phantom\'s speech \b'
	menuContents { 
		"\b";
		glob.suspPause = true;
		try {	local str = capt({:textObj.phantomTxt});
			str = str.findReplace(';;;','\b\ \ ');
			str = str.findReplace(',,,','\n\ \ ');
			"<<str>>"; }
		finally glob.suspPause = nil;
		 } ;
+ MenuLongTopicItem '<font size=+1><tt><i>\ \ \ &lt;=o=&gt;\ \ Abbreviated speech\ \ \ \ \ &lt;=o=&gt;\ </i></tt></font>'
	heading = '\ - Recap of the Phantom\'s speech \b'
	menuContents { 
		"\b";
		textObj.phantomTxtShort; 
		 } ;

remTempleDirs: MenuLongTopicItem '\ - Directions to the <<outsideTemple.seen ? 'temple' : 'landform in the rainforest'>> \b'
	menuContents = "From the Wolds of the Western Marches, go northwest. From that point, go northwest, west, north, west. You will be at the temple rock, and can then enter the fissure. " ;
rememberTemple: MenuLongTopicItem '\ - The temple floor \b'
	menuContents { "<< qGraphics() ? 'You saw something like this: \b\ \ <.i><.c><IMG SRC=\'newness.png\'><./c>' : 'It seemed to you that some large-scale lettering was created by the network of irregular seams between the flagstones; we had said \"seems\" because the letters had very jagged and asymmetrical edges that blended closely with the shapes of those flags which were not part of the lettering or any other particular pattern. \n\ \ Nonetheless, you believed the letters \"<tt> NE W N E S S </tt>\" to have been worked across the temple floor. '>>"; } ;
rememberYimnaru: MenuLongTopicItem '\ - Yimnaru about the magic bean \b'
	menuContents { "Concerning the bean\'s whereabouts and the island of Uzumbung, Yimaru had said: \n\ \ <<yimUz.txt>>";  } ;
rememberWizNotes: MenuLongTopicItem '\ - The Wizard\'s notes in the library \b'
	menuContents { 
		local str = capt({:"<<monkWritings.txt>>"});
		str = str.findReplace(';;;','\b\ \ ');
		str = str.findReplace(',,,','\n\ \ ');
		"The notes had said: \n\ \ <<str>>"; } ;
remWitchDirs: MenuLongTopicItem '\ - Directions to the Witch\'s hut \b'
	menuContents = "From the lavender-covered uplands, go southeast. Then go east, southwest, south, up, and northeast. " ;
rememberSmithy: MenuLongTopicItem '\ - The smithing process \b'
	menuContents { "<<msg>>"; }
	msg = '\ \ Here is the process: put the horseshoes in the forge coals. Pump the bellows until the coals are white-hot. Wait for the horseshoes to get red-hot, then take them with the tongs. Put the shoes on the anvil. Position the punch on the shoes. Hit the punch with the smithy hammer. '	;

stuck(cond=true) {
	if(cond) { 
		// cWSC(nil,nil,function{"STUCK\n";sst();});
		savepointOff();
		stuckObj.stuckDmn.start; } }
	stuckObj: object
		stuckDmn: RDaemon {
			autoLink = nil
			fireAtCt = 10
			startEffects(t?) { fireAtCt = randRange(7,15); }
			events { if(gpc.lastAction.baseActionClass is in(LookAction,WaitAction,AgainAction)) --ct; 
				if(ct>=fireAtCt) { 
					reset; // before stuckMsg to ensure savepointOn can find us inactive
					stuckObj.stuckMsg;   }  }
		}
	    stuckMsg { "\b\b\ \ [ATTENTION!: Somewhere in the recent past, you\'ve either done something or not done something which has resulted in making the game unwinnable. Would you like to find yourself transported back to a point where things have not gone awry? (Y to confirm, N to play on as is)]";
			local f = function{
				gLibMessages.mainCommandPrompt(rmcCommand);
				local inp = GetInput;
				if(inp.toLower() is in('yes','y','yeah','yep','ok','o k','o.k.','okay')) { 
					undoInv();  
					gpc.lookAround(true);
					return true; } 
				else if(inp.toLower() is in('n','no')) { "As you wish. Note that any saving after this point will result in a saved file from which the game can not be won. ";
					return true; }
				else { "We\'re just looking for a Y or an N here, so we do what you want to do. ";
					return nil; }
				};
			while(!f()) ;
			savepointOn(); }  	;

savepointOn() { 
		//* another source may have permanently stuck the game: don't turn savepoint back on
	if(stuckObj.stuckDmn.isActive) return;  
	libGlobal.suspendUndoSave = nil;
	libGlobal.tentativeStuck = nil; }
savepointOff(t?) { 
	libGlobal.suspendUndoSave = true;
	if(t) libGlobal.tentativeStuck = true;
	else libGlobal.tentativeStuck = nil; }
undoInv() { undo();		
		invNote();
		inventoryWindowDaemon.beforePrompt; }

preSave: PreSaveObject execute {
		gReveal('gameSaved');
		local look = nil;
		if(noSave) { 
			if(glob.slideshowMode && !gR('slidesave')) {
				Thing.fC('<.p>You have entered autonomous commands since the last readthrough step. We regrettably cannot save autonomous changes if the game is to stay in readthrough mode. If you wish to save your autonomous changes, you can first enter READTHROUGH OFF, and then SAVE... just note that you will be unable to reenter readthrough mode from that point. If you wish to save the game in readthrough mode, enter SAVE again, but be aware that we will undo the game to the state it was in at the last readthrough step. <.r slidesave><.p>');
			}
			else if(glob.slideshowMode) "<.p> <b>We return the game to</b> the readthrough sequence before saving... <.p>";
			else if(libGlobal.tentativeStuck) "<.p>You are indeed able to save this game, but circumstances are such that the game is in at least some potential danger of becoming unwinnable. We are going to back up a little to avoid the complications. <.p>";
			else "<.p>You are indeed able to save this game, but we must inform you that somewhere relatively recently along the line you have brought the game into an unwinnable state. Before saving, we are taking the liberty of shifting your position just back to a point where things have not yet gone awry. <.p>";
			undoInv();  
			savepointOn();
			look = true; }
		if(kusamenjin.evacuate.isActive && kusamenjin.evacuate.ct > 15) {
			kusamenjin.evacuate.ct = 15;
			Each(inTannery.aCts) if(obj.isPortable && (!obj.location.isPortable || obj.location==buffaloHide) && obj not in (keg,buffaloHide)) { obj.mIFT(gpc); look = true; }
			invNote(); 	} 
        if(keg.abandonDmn.isActive && keg.abandonDmn.ct) { //should be unreachable if abandondmn has saveptOff
            keg.abandonDmn.reset;
            keg.saveFlag = true; }
		if(wanderDmn.isActive && wanderDmn.ct > 8) wanderDmn.ct = 8;
		if(breatheDmn.ct>=7 && gor.bottomLayer || breatheDmn.ct>=8 && !gor.bottomLayer && !gor.topLayer) "<.p>We warn you that you are probably about to drown, and saving may not be much good. <.p>";
		if(gor.oK2([LightningLoc,GeyserLoc])) {
			gpc.mIFT(beforeLightning);
			prince.mIFT(beforeLightning);
			look = true; }
		if(look) { gpc.lookAround(true); "<.p>"; }
		}
    storedInv = nil
;
PostUndoObject execute {
		if(kusamenjin.evacuate.isActive && kusamenjin.evacuate.ct > 15) {
			kusamenjin.evacuate.ct = 15;
			Each(inTannery.aCts) if(obj.isPortable && (!obj.location.isPortable || obj.location==buffaloHide) && obj not in (keg,buffaloHide)) obj.mIFT(gpc);
			invNote(); } 
        if(keg.abandonDmn.isActive && keg.abandonDmn.ct) {
            keg.abandonDmn.ct = 0; }
		// if(wanderDmn.isActive && wanderDmn.ct > 8) wanderDmn.ct = 8;
		if(wanderDmn.isActive && !outsideHut.seen && !knights.cS.oK(KnightGuideState)) {
			wanderDmn.reset;
			if(gpc.isIn(horse)) horse.mIFT(knightsLoc);
			else {
				gpc.mIFT(knightsLoc); 
				prince.mIFT(knightsLoc); }
			}
}
;
modify UndoAction
	performUndo(asCommand) {
		local s = noSave;		//
		local t = libGlobal.tentativeStuck;		//
		local nd = slideshow.needsDecr;
		local ld = gpc.lastDobj;
		if(glob.slideshowMode && slideshow.lastCmd.find('.')) { "<.p>Apologies... we cannot perform an undo after a string of multiple commands. ";
			return nil; }
		if (undo())        {
            PostUndoObject.classExec();
            local oldActor = gActor; local oldIssuer = gIssuingActor; local oldAction = gAction;
            gActor = gPlayerChar; gIssuingActor = gPlayerChar; gAction = self;
            try        {
                if(!s && !glob.slideshowMode) gLibMessages.undoOkay(libGlobal.lastActorForUndo, libGlobal.lastCommandForUndo);
				else if(glob.slideshowMode) {
					if(s) "<.p>We now return to the last auto-play step. <.p>";
					else "<.p>Undone. \b";
					if(nd) {
						--slideshow.stepCt;
						slideshow.needsDecr = nil;
					}
					if(!asCommand) slideshow.scriptedUndo = true; 
				}
				else if(t) "<.p>There have recently arisen some complications which may or may not put the game in danger of becoming unwinnable. To be safe, we are undoing moves to a point just before the complications. <.p>";	//
				else "<.p>We are constrained to give you notice that the goal of your adventure, as circumstances currently stand, has recently become unachievable. Instead of undoing your last action alone, we are undoing your moves back to a point where nothing has yet gone awry as far as ultimate success is concerned. <.p>";			//

				if(!glob.slideshowMode && ld==wKnight && qGraphics())
					chessboard.showBoard;
                else if(!glob.slideshowMode) libGlobal.playerChar.lookAround(true);		//
            }
            finally { gActor = oldActor; gIssuingActor = oldIssuer; gAction = oldAction; }
            if (asCommand)  AgainAction.saveForAgain(gPlayerChar, gPlayerChar, nil, self);
			savepointOn();
			// slideshow.needsUndo = nil;
			invNote();
			inventoryWindowDaemon.beforePrompt;
            return true;        }
        else        {
            gLibMessages.undoFailed();
			// leave savepoint as is? 
            return nil;       }
		}
;

//* this is for UNDO if game is unwinnable
modify executeAction(targetActor, targetActorPhrase,issuingActor, countsAsIssuerTurn, action){
		local rm, results;
	startOver:
		rm = GlobalRemapping.findGlobalRemapping(issuingActor, targetActor, action);
		targetActor = rm[1];
		action = rm[2];
		results = new BasicResolveResults();
		results.setActors(targetActor, issuingActor);
		try    {
			action.resolveNouns(issuingActor, targetActor, results);}
		catch (RemapActionSignal sig){
			sig.action_.setRemapped(action);
			action = sig.action_;
			goto startOver;    }
		if (action.includeInUndo
				&& action.parentAction == nil
				&& (targetActor.isPlayerChar()
					|| (issuingActor.isPlayerChar() && countsAsIssuerTurn))
				&& !libGlobal.suspendUndoSave)	{  					//
			libGlobal.lastCommandForUndo = action.getOrigText();
			libGlobal.lastActorForUndo = (targetActorPhrase == nil ? nil : targetActorPhrase.getOrigText());
			savepoint(); }
		if (countsAsIssuerTurn && !action.isConversational(issuingActor)) {
			issuingActor.lastInterlocutor = targetActor;
			issuingActor.addBusyTime(nil,issuingActor.orderingTime(targetActor));
			targetActor.nonIdleTurn();}
		if (issuingActor != targetActor
				&& !action.isConversational(issuingActor)
				//* to debug issued commands, print before this (originally all dp was in doAction)
				&& !targetActor.obeyCommand(issuingActor, action))    {
			if (issuingActor.orderingTime(targetActor) == 0)
				issuingActor.addBusyTime(nil, 1);
			action.saveActionForAgain(issuingActor, countsAsIssuerTurn,targetActor, targetActorPhrase);
			throw new TerminateCommandException();    }
		action.doAction(issuingActor, targetActor, targetActorPhrase,countsAsIssuerTurn); }




randRange(min,max) { local range = new Vector(max-min+1);
	while(min <= max) { range.app(min); ++min; } return rand(range); }
	
end(
	msg = rand(
		'Being alive was highly overrated',
		'Your adventures have ended, due to the expiration of your lifespan',
		'Your adventures have ended, due to the termination of your mortal life',
		'You\'ve just taken the express route to the Overworld',
		'You\'ve just failed with flying colors',
		'You just perfected the art of dying', 
		'You died and now you\'re dead',
		'You have effectively died',
		'You have died till you\'re dead',
		'You have successfully died',
		'Being dead has significantly reduced your chances of succeeding',
		'The continuation of your quest has been permanently cancelled,,,on account of you\'re dead',
		'Death has put a considerable damper on any further plans'
			)) { 
	local fi = deathMusic.getVal;
	"<sound src='<<fi>>.ogg' volume=30 layer=background>";
	finishGameMsg(msg, finishOptionUndo); } 

transient deathMusic: object
	ct = 1
	getVal { return ct++ % 2 ? 'death1' : 'death2'; }
;

know(...) { for(local i in 1..argcount) gSetKnown(getArg(i)); } 
markActed(...) { for(local i in 1..argcount) getArg(i).noteAct; }

gDir() { if(gAction.propDefined(&getDirection) && gAction.getDirection()!=nil)
		return gAction.getDirection().dirName;
	else if(gAction.getOriginalAction().propDefined(&getDirection) && 
		gAction.getOriginalAction().getDirection()!=nil)
		return gAction.getOriginalAction().getDirection().dirName;
	else if(gAction.parentAction && gAction.parentAction.propDefined(&getDirection) && 
		gAction.parentAction.getDirection()!=nil)
		return gAction.parentAction.getDirection().dirName;
	else return nil ; } 
	
rIobj(obj) { 
	if(obj.isClass()) {
		if(gIobj) return gIobj.oK(obj);
		return gTentativeIobj && gTentativeIobj.length > 0 && gTentativeIobj.iW({x:x.obj_.oK(obj)}); }
	else if(gIobj) return gIobj==obj;	
	return gTentativeIobj && gTentativeIobj.length > 0 && gTentativeIobj.iW({x:x.obj_==obj}); }
rDobj(obj) { if(obj.isClass()) {
		if(gDobj) return gDobj.oK(obj);
		return gTentativeDobj && gTentativeDobj.length > 0 
			&& gTentativeDobj.iW({x:x.obj_.oK(obj)}); }
	else if(gDobj) return gDobj==obj;	
	return gTentativeDobj && gTentativeDobj.length > 0 
		&& gTentativeDobj.iW({x:x.obj_==obj}); }

numSeen(func) { local lst = gpc.visibleInfoTable.keysToList;
	return lst.countWhich(func); }
	//*in-scope obj is implied v v
objWhich(func) { if(gac==nil) return nil;
	return gac.connectionTable.keysToList.valW(func); }

oppDir(dirProp) { switch(dirProp) {
	case &north: return &south; case &east: return &west; case &west: return &east; case &down: return &up;
	case &south: return &north; case &northeast: return &southwest; case &southwest: return &northeast;
	case &northwest: return &southeast; case &southeast: return &northwest; case &up: return &down; 
	default: return nil; } }
	
PQI(item,which?) { if(which) prince.addTakeTurnItem(item,which);
	else prince.addTakeTurnItem(item); }	

//////////////////       C L A S S E S    A N D    L I B R A R Y   M O D S    /////////////////////////

pQInit: PreinitObject
	execBeforeMe = [adv3LibPreinit]
	execute() {   
		eventManager.removeMatchingEvents(conversationManager,&topicInventoryDaemon);
		// eventManager.removeMatchingEvents(tipManager,&showTips);		//need footnote tip
			// Custom RoomParts
		fEI(Room,function(rm) {
			if(rm.cRoomParts!=nil && rm.cRoomParts.oK(Collection)) {
				foreach(local pt in rm.roomParts) 
					if(pt.oK(DefaultWall)) { rm.cts -= pt; rm.roomParts -= pt; }
				foreach(local wl in DefaultWall.allWalls) {
					if(rm.cRoomParts.iO(wl.enm)) { rm.roomParts += wl;
						rm.cts += wl; } } } });
		fEI(CRoomPart, function(pt) {
			local rm = pt.location;
			if(pt.replaceObj.oK(Collection)) foreach(local oldpt in pt.replaceObj) {
				rm.cts -= oldpt;
				rm.roomParts -= oldpt; }
			else { if(rm) { rm.cts -= pt.replaceObj;
				rm.roomParts -= pt.replaceObj; }}
		//* std. preinit should add CRoomPart to rm.cts and rm.roomParts
			});

			/* The Walls class removes default walls from scope, then adds directional vocab to itself 
			* based on the "walls" property which contains enums corresponding to the locations of 
			* that room's walls (since not every room is a simple n,e,s,w situation). If there is a 
			* special user-defined wall present (suppose the west wall had some extraordinary features)
			* the Walls object will not take on vocab for that direction. */
		fEI(Walls,function(wl) { local rm = wl.location;
			if(rm) { local pt, enm;
				foreach(pt in rm.roomParts) if(pt.oK(DefaultWall)) rm.roomParts -= pt;
				foreach(pt in rm.cts) if(pt.oK(DefaultWall)) rm.cts -= pt;
				foreach(enm in wl.walls) if(rm.cts.valW({pt:pt.oK(CRoomPart) 
													&& pt.wallEnum==enm})) continue;
					else { local cls = libGlobal.allDirItems.valW({itm:itm.wallEnum==enm});
						local lst = [cls] + wl.getSuperclassList();
						wl.setSuperclassList(lst);
						}
				wl.initializeVocab();
				} 
			});
			 // * * TOPIC DATABASES * * //
		local vec = new Vector(60);
		fEI(ActorTopicDatabase, {x: vec.append(x)} );
		foreach(local cur in vec) { 
			// if(cur.oK(Animal)) { cur.addTopic(new AnimalASKdef(cur));
			// 	cur.addTopic(new AnimalTELLdef(cur)); 
			// 	cur.addTopic(new AnimalANYdef(cur)); 
			// 	cur.addTopic(new AnimalSHOWdef(cur));
			// 	cur.addTopic(new AnimalGIVEdef(cur)); }
			// ^ ^ seemed to cause rte if object added its own DefaultTopic in add to these
			 { cur.addTopic(new UnknownDefaultAskTopic(cur));
				cur.addTopic(new UnknownDefaultTellTopic(cur));
				cur.addTopic(new UnknownDefaultAskForTopic(cur)); }
				} 
			// * * ACTOR STATE * * if they aren't Thing-derived, I can't remap dobjFors to a state.
                //  Library and sample source suggest: dobjFor(AskAbout) {Ac { curState.askAbout(); } 
                //  but then I can only encapsulate the action phase and not verify and check. 
				// actorStateD(I)objFor(action) macro alone doesn't allow use of failCheck, because 
				// actorStates aren't Thing-derived
		// local aslst = ActorState.getSuperclassList();		
		// aslst = aslst.append(SecretFixture);
		// ActorState.setSuperclassList(aslst);    //don't delete till convinced actorStateDF works okay 
				// * * TOPIC * * //
		Topic.setSuperclassList([SecretFixture]);
			// * * MISC * * //
		fEI(Direction, function(x) { 
			if(x.dirProp==&north) x.dirName = 'north' ;
			else if(x.dirProp==&northeast) x.dirName = 'northeast' ;
			else if(x.dirProp==&east) x.dirName = 'east' ;
			else if(x.dirProp==&southeast) x.dirName = 'southeast' ;
			else if(x.dirProp==&south) x.dirName = 'south' ;
			else if(x.dirProp==&southwest) x.dirName = 'southwest' ;
			else if(x.dirProp==&west) x.dirName = 'west' ;
			else if(x.dirProp==&northwest) x.dirName = 'northwest' ;
			else if(x.dirProp==&in) x.dirName = 'in' ;
			else if(x.dirProp==&out) x.dirName = 'out' ;
			else if(x.dirProp==&up) x.dirName = 'up' ;
			else if(x.dirProp==&down) x.dirName = 'down' ; } );
		fEI(AutoReturn, {x:x.pqInit()});	
		fEI(Building, {x:x.pqInit()});	
		fEI(QuarryWater, function(x) {if(!x.oK(QWS)) QuarryWater.allLocs.append(x);}); 
		fEI(QuarryWaterSurface, {x: QuarryWater.allSLocs.append(x)});  
		fEI(CrossTile, {x: CrossSlot.validContents += x});
		fEI(RainforestBase, {x: RainforestBase.allLocs.append(x)}); 
		fEI(SeaLocBase, {x: SeaLocBase.allLocs.append(x)}); 
		fEI(SpurnLoc, {x: SpurnLoc.allLocs.append(x)});
		fEI(RainforestLoc, {x:x.pqInit()});	
		fEI(SeaLoc, {x:x.pqInit()});
		fEI(EventListItem, {x:x.pqInit()});	
		BlueFlowers.pqInit();
		}
	;
	// ! any reason that all superclass changing should happen before initializeThing?

// respectMeter: object
// 	meter = 20
// 	change(delta) { meter += delta;
// 		if(meter <= 0) "<.p>It's just too much. Once too often your conduct has served to make Prince Quisborne question your example or else to just be outright ashamed of you. ***He announces that he's going home, etc. "; 
// 		end('Even a feckless prince didn\'t think you were worth following'); }
// if used, add multiple ending texts?
// (tear wallpaper on second time after warning that you should leave it for new owners)

	
dummy: Thing vW = 'burning blazing blaze/flame/flames/fire/smoke/smell/money/coin/coins' name = 'object' isKnown = true ;

clinging: Posture   participle = 'clinging' 
		tryMakingPosture(loc) { return tryImplicitAction(Climb, loc); }
        setActorToPosture(actor, loc) { nestedActorAction(actor, Climb, loc); };
swimming: Posture   participle = 'swimming' 
        tryMakingPosture(loc) { return tryImplicitAction(SwimIn, loc); }
        setActorToPosture(actor, loc) { nestedActorAction(actor, SwimIn, loc); }	;
riding: Posture   participle = 'riding'  
        tryMakingPosture(loc) { return tryImplicitAction(Ride, loc); }
        setActorToPosture(actor, loc) { nestedActorAction(actor, Ride, loc); }	;
	
raftBarrier: TravelBarrier	cTP { return traveler!=raft; }
	eTB { "You\'re still on the raft, and you can\'t sail that direction. "; }	;
class HorseBarrier: TravelBarrier cTP { return traveler!=horse; }
	construct(msg) { inh; horseWontGo = msg; }
	horseWontGo = nil
	eTB { "<<horseWontGo>>"; } ;
class HybridBarrier: TravelBarrier cTP { return !traveler.oK(Hybrid); }
	construct(msg) { inh; wontGo = msg; }
	wontGo = nil
	eTB { "<<wontGo>>"; } ;

wetState: ThingState stateTokens = ['wet','damp','moist'] ;
	
  class SpecialNounPhraseProd: NounPhraseWithVocab
    getMatchList = []
    getVocabMatchList(resolver, results, flags) {
        return getMatchList().subset({x: resolver.objInScope(x)})
            .mapAll({x: new ResolveInfo(x, flags)}); }
	;
	
grammar aroundSingleNoun(main):
   singleNoun->np_ | 'around' singleNoun->np_ : PrepSingleNounProd	;
grammar underSingleNoun(main):
   singleNoun->np_ | 'under' singleNoun->np_ : PrepSingleNounProd	;
grammar nearSingleNoun(main):
   singleNoun->np_ | ('near'|'by'|'against') singleNoun->np_ : PrepSingleNounProd	;
grammar overSingleNoun(main):
   singleNoun->np_ | 'over' singleNoun->np_ : PrepSingleNounProd	;

  class UDTI: TopicEntry 
	tR = "<.i>What you're trying to <<verb>> is either something you don\'t know about yet, or else it\'s not a part of your adventure. " 
	construct(loc) { location = loc; }
	verb = 'tell about'
	isConversational = nil
	isActive = Gbm == nil || !gpc.knowsAbout(Gbm)  ;
  class UnknownDefaultAskTopic : UDTI, DefaultAskTopic 
	matchScore = 110 	verb = 'ask about' ;
  class UnknownDefaultAskForTopic : UDTI, DefaultAskForTopic 
	matchScore = 110 	verb = 'ask for' ;
  class UnknownDefaultTellTopic : UDTI, DefaultTellTopic 
	matchScore = 110 ;
  class AnimalASKdef: DefaultAskTopic tR = "You weren\'t really expecting a response, were you? "
	construct(loc) { location = loc; } ;
  class AnimalTELLdef: DefaultTellTopic tR = "You weren\'t really expecting a reaction, were you? "
	construct(loc) { location = loc; } ;
  class AnimalGIVEdef: DefaultGiveTopic tR = "<<one of>>As you contemplate the idea of giving <<gDobj.tN>> to <<gA.tN>>, you decide it\'s not worth the trouble. <<or>>With strong suspicions that <<gA.tN>> will not be interested in your offering, you desist from giving <<gA.itObj>> <<gDobj.tN>>. <<shuffled>>"
	construct(loc) { location = loc; } ;
  class AnimalSHOWdef: DefaultShowTopic tR = "<<one of>>If <<gA.tN>> <<gA.verbToBe>> impacted in any way by your presentation, <<gA.itNom>> <<gA.doesnt>> show it. <<or>>{The iobj/he} look{s} for a few fleeting moments, but <<gA.doesnt>> otherwise alter what <<gA.itIsContraction>> doing. <<shuffled>>"
	construct(loc) { location = loc; } ;
  class AnimalANYdef: DefaultAnyTopic, SHUF ['Your efforts are wasted on <<gA.tN>>. ', '\^<<gA.tN>> <<gA.verbToHave>> no visible reaction to your action. ']
	construct(loc) { location = loc; } ;

  class HELLOx: HELLO matchList = [helloTopicObj] ;
  class BYEx: BYE matchList = [byeTopicObj] ;
	
  class AtList: VSHUF, SHUF1
	eP = 40 
	eRA = perInstance(firstEvents != nil && firstEvents.length ? firstEvents.length : 3)
	eRT = 22
	//* roomDaemon will never call atmosphereList.dS if(loc.noAtmIfPQ && prince.firedThisTurn)
	doScript { 
		// local firstLst = firstEvents;
        local firstLen = firstEventsLen;
        local lst = eventList;
        eventListLen = lst.length();
		if(!useOnFirstEntry && !callCt || suppressCond
				|| (!firstLen || pastFirst) && !eventListLen) { ++callCt; return; }
		++callCt;																			//
        if (!checkEventOdds()) { firedLastTurn = nil; return; }								//
		local evt=-1,p;
		if((evt=checkPriorityFire??-1) not in (nil,-1)) ;
		else if((p = pendingItems.valW({x:x.isReady})) != nil) {					//
			evt = p;
			pendingItems.rem(p); }
		else if (curScriptState <= firstLen) { 
			evt = firstEvents[getNextRandom1()];
			curScriptState++; }
        else if (!shuffleFirst && curScriptState <= firstLen + eventListLen) { 
			evt = lst[curScriptState++ - firstLen]; }
        else { pastFirst = true;
			local usingGen = nil;
			if(inclGenAtmos || lP && lP.inclGenAtmos) {
				local odds = 50;	//* if a room has at least 4 unique atmsgs, use them half the time
				if(genOdds) odds = genOdds; //unused
				else if(eventListLen<4) odds = 25; //* 3 or less, only call them 1/4 of the time
				else if(eventListLen>7) odds = 75;
				if(rand(100)+1>odds) {
					evt = outdoorAtmosphere;
					usingGen = true; }
				}
			if(!usingGen) {
				local gnr = getNextRandom;
				if(gnr<=lst.length) evt = lst[gnr];
				}		}
        doScriptEvent(evt); }
	soundAtmos { if(!lP) { next; return; }
		local s = lP.cts.valW({x:x.oK(SimpleNoise)});
		if(!s) next;
		else s.desc; }
	genOdds = nil //unused
	;
  
  class StopList: ShuffledList		//* for transience
	getNextValue() { ++valuesAvail; 
		if(valuesAvail>=valueList.length) return valueList[valueList.length];
		else return valueList[valuesAvail]; }
	;
	//* bear in mind SHUF does not increment its script state unless it is firing firstEvents or !shuffleFirst; doesn't call scriptDone or advanceState
  class ShufFirstEventList: SHUF
	doScript() { 
		// local firstLst = firstEvents;
		local firstLen = firstEventsLen;
		local lst = eventList;
		eventListLen = lst.length();
		if(!useOnFirstEntry && !callCt || suppressCond
				|| (!firstLen || pastFirst) && !eventListLen) { ++callCt; return; }
		++callCt; 
		if (!checkEventOdds()) { firedLastTurn = nil; return; }
		local evt=-1,p;
		if((evt=checkPriorityFire??-1) not in (nil,-1)) ; //*pass to keep evt as is
		else if((p = pendingItems.valW({x:x.isReady})) != nil) {
			evt = p;
			pendingItems.rem(p); }
		else if (curScriptState <= firstLen) { 
			evt = firstEvents[getNextRandom1()];
			curScriptState++; }
		else if (!shuffleFirst && curScriptState <= firstLen + eventListLen)
			{ evt = lst[curScriptState++ - firstLen]; }
		else { pastFirst = true;
			local gnr = getNextRandom;
			if(gnr<=lst.length) evt = lst[gnr]; }
		doScriptEvent(evt); 
		}
	getNextRandom1() { if(shuffledList1_ == nil) {
        	shuffledList1_ = new ShuffledIntegerList(1, firstEventsLen);
		shuffledList1_.suppressRepeats = suppressRepeats; }
		return shuffledList1_.getNextValue(); }
	shuffledList1_ = nil
	;
  
  class PeriodicShuffledEventList: SHUF
	checkEventOdds { return !(callCt % interval); }
	interval = 1
	;
  class PeriodicShufFirstEventList: SHUF1
	checkEventOdds { return !(callCt % interval); }
	interval = 1
	;
  class VariableLengthShuf: SHUF
	//* if our eventList is populated with EventListItems that may be one-off, weed the finished ones out right before reshuffle
	getNextRandom { 
		if (shuffledList_ == nil) {
            shuffledList_ = new ShuffledIntegerList(1, eventListLen);
            shuffledList_.suppressRepeats = suppressRepeats;
        	}
		//* these changes should take effect right before the underlying shuffledList_ performs a reshuffle, so the valuesAvail will be in sync with our actual eventList length. This whole block perhaps could have been an override of reshuffle() on the ShuffledIntegerList object
		if(shuffledList_.valuesAvail==0) {
			local ele = 1;
			local rem = new Vector;
			Each(eventList) {
				if(dataType(obj)==TypeObject && obj.oK(EventListItem) && obj.isDone) rem.app(obj); }
			eventList = eventList - rem;
			pendingItems = pendingItems - rem;
			shuffledList_.rangeMax = eventList.length;
			shuffledList_.valueList = List.generate({i: ele++}, eventList.length);
			shuffledList_.valuesVec = new Vector(shuffledList_.valueList.length(), shuffledList_.valueList);
			}
		// dp(shuffledList_.valueList.length)
		// if(shuffledList_.valuesVec) dp(shuffledList_.valuesVec.length)
		// dp(shuffledList_.valuesAvail)
		return shuffledList_.getNextValue;  	}
;
  class EventListItem: object	
	pqInit() { 
		if(doneAtCt) 
			setMethod(&isDone, method{ return fireCt >= doneAtCt; } );
		if(myListObj && initiallyActive) { 
			for(local i in 1..weight) myListObj.(whichList) += self; }
		else if(initiallyActive && location && location.propDefined(whichList) && 
				location.(whichList)!=nil && location.(whichList).oK(Collection)) {
			for(local i in 1..weight) location.(whichList) += self;
			myListObj = location; } }
	whichList = &eventList
	myListObj = nil
	weight = 1
	actor = nil
	room = nil
	isReady = gClock >= readyTime && dayCt >= readyDay && !isDone 
		&& (delays ? lClockPlus(delays[1]) && lDayPlus(delays[2]) : true)
    readyTime = 0
	readyDay = 0
	lastDay = 0
	lastClock = 0
	lastFireCtOfMyObj = 0
		//* any global functions, class or actor methods that dynamically add items are responsible to set addedOnXx on the item. (prince.addTakeTurnItem does it)
	addedOnDay = nil
	addedOnClock = nil
    setDelay(turns)    {
        readyTime = gClock + turns;
        return self;    }
	setDayDelay(days) { readyDay = dayCt + days; return self; }
	setBothDelay(turns,days) { readyTime = gClock + turns;
		readyDay = dayCt + days; 
		return self; }
	oneOff = nil
	delays = nil //* must be a list of turns,days: [80,2]
	_invokeItem() { invokeItem(); 
		if(!oK(ShuffledEventList)) ++fireCt;	//* hope that fireCt will be icmtd by doScriptEvent
		lastDay = dayCt;
		lastClock = gClock;
		if(myListObj) lastFireCtOfMyObj = myListObj.fireCt;  //* If we are the listobj's first fired item, its fireCt will still be 0 when we're invoked;
		if(oneOff) done; }
    invokeItem() { }
	fireCt = 0
	doneAtCt = nil
    isDone = nil
	setDone() { isDone = true; }
    initiallyActive = true
	getActor { if(location.oK(ActorState)) return location.gA;
		else return location; }
	//explicitly set location prop for getActor, if obj doesn't use plus notation
    resetItem()    { if(propType(&isDone) != TypeCode) isDone = nil; }
    agendaOrder = 100	// prob not using
//* condition-checking convenience methods	
	lDayPlus(num) { return !fireCt || dayCt >= lastDay + num; }
	lClockPlus(num) { return !fireCt || gClock >= lastClock + num; }
	lObjFirePlus(num) { return !fireCt || myListObj && myListObj.fireCt >= lastFireCtOfMyObj + num; }
	aDayPlus(num) { return addedOnDay && dayCt >= addedOnDay + num; }
	aClockPlus(num) { return addedOnClock && gClock >= addedOnClock + num; }
;
  class ELI1: EventListItem
	oneOff = true	;
  class ELIactor: ELI1 		//* turn off oneOff for any ELIactors that can repeat
  	_invokeItem { inh; if(other) other.noteAct; }
  	iR = inh && (other ? (other.oK(Collection) ? other.valW({x:actor.canSee(x)}) : actor.canSee(other)) : true) && 
		(room ? (room.oK(Collection) ? room.iO(actor.Gor) : actor.isIn(room)) : true)
	other = nil
	room = nil
	actor = nil ;

  class ALI: EventListItem		//* AtmosphereListItem
	pqInit() { if(location && location.pD(&atmosphereList) && location.atmosphereList!=nil
				&& location.atmosphereList.pD(whichList) && location.atmosphereList.(whichList)!=nil
				&& location.atmosphereList.(whichList).oK(Collection)) {
			location.atmosphereList.(whichList) += self;
			myListObj = location.atmosphereList; }
		else inh;  }  	;
  class ALI1: ALI
	oneOff = true	
;
modify EventList
	next() { //possible that this would mess things up if scriptDone() has any complexity
		//local c = curScriptState;
		advanceState;	
		//dp(nextCt) ///////////////////////
		//if(c==curScriptState) ++curScriptState; would make list jump by two?
		if(nextCt<=eventList.length + (firstEvents!=nil ? firstEvents.length : 0) + 1) { 
			++nextCt;
			--fireCt; //* assuming here that the dS call within a dS routine will up the fireCt twice but only end up showing one event. 
			dS;
			return true;
			}
		else { firedLastTurn = nil; 
		// "OVERFLOW\n";				////////////////////
		return nil; } 
		}	
	nextCt = 0
	callCt = 0
	fireCt = 0
;
modify ShuffledEventList
	useOnFirstEntry = true
	firedLastTurn = nil
	suppressCond = nil
	pastFirst = nil
	firstEventsLen = (firstEvents.length )
	shownAll { return fireCt >= firstEventsLen + eventList.length + priorityList && priorityList.oK(List) ? priorityList.length : 0; }
	eLCanFire() { local len = eventList.length;
		return len && eventList.iW({f:dataType(f)!=TypeObject || !f.oK(ELI) || f.isReady && !f.isDone}); }
	canFire() { local flen = firstEventsLen;
		return flen && curScriptState <= flen 
				&& firstEvents.sublist(curScriptState).iW(
						{f:dataType(f)!=TypeObject || !f.oK(ELI) || f.isReady && !f.isDone}) ||
				eLCanFire();		}
	doScript(next?) { 
		local firstLst = firstEvents;
        local firstLen = firstLst.length();
        local lst = eventList;
        eventListLen = lst.length();
		if(!useOnFirstEntry && !callCt || suppressCond
				|| (!firstLen || pastFirst) && !eventListLen) { 
			++callCt; return; } 		//
		++callCt;																			//
        if (!checkEventOdds()) { firedLastTurn = nil; return; }								//
        local evt = -1, p;
		if((evt=checkPriorityFire??-1) not in (nil,-1)) ; //*pass to keep evt as is
			//* if an EventListItem object previously had its number called, but its condition wasn't ready, we will give first priority to trying to execute it until it succeeds. If it (or any others like it) is still not ready, then get the next shuffled item. 
		else if((p = pendingItems.valW({x:x.isReady})) != nil) {					//
			evt = p;
			pendingItems.rem(p); }
        else if (curScriptState <= firstLen) { evt = firstLst[curScriptState++]; }
        else if (!shuffleFirst && curScriptState <= firstLen + eventListLen) { 
			evt = lst[curScriptState++ - firstLen]; }
        else { pastFirst = true; 										//
			local gnr = getNextRandom;
			//dp(gnr) dp(lst.length)			/////////
			if(gnr<=lst.length) 
				evt = lst[gnr];
				//! do we try our next random if gnr>lst.length, or simply let evt remain nil/-1 and pass this turn?
				 }
        doScriptEvent(evt); }
	doScriptEvent(evt) {
        switch (dataTypeXlat(evt)) {
			case TypeSString:
				say(evt); 
				if(evt=='') evt = -1;	//
				break;
			case TypeObject:
				if(evt.oK(ELI)) {
					local fired = doELI(evt);					//
					if(!fired) evt = -1;	}					//
				else evt.doScript(); 
				break;
			case TypeFuncPtr:
				(evt)(); break;
			case TypeProp:
				self.(evt)(); break;
			case TypeInt:									//
				break;		//* if getNextRandom picks an index that's higher than our eventList length, -1 will be passed to dSEvent
			default: evt = -1; }      //* for nil
		nextCt = 0;		 				//
		if(evt==-1) return;		//* an ELI tried to call next(), but nothing was ready or left. We don't want to register as firing if the selected item didn't print
		firedLastTurn = true; 
		++fireCt;		}
	checkPriorityFire() { 
		if(!priorityList || !priorityTrumpsFirst && fireCt<firstEventsLen) return nil;
		foreach(local ch in priorityList) {
			if(!gR(ch[3]) && (fireCt>=ch[2] || !rand(ch.length==4 ? ch[4] : 4))) return ch[1];
		}
		return nil; }
	priorityList = nil
	priorityTrumpsFirst = true
	doELI(evt) { 
		local res = true;
		if(evt.isDone) res = next(); //* in case an ELI uses 'done' and we're not of class VSHUF
		else if(evt.isReady) evt._invokeItem; 
		else { if(!pendingItems.iO(evt)) pendingItems.app(evt);
			res = next(); }
		return res; }
	vamp { if(eLCanFire) doScriptEvent(eventList[getNextRandom]); }
	pendingItems = perInstance(new Vector(6))
	;	



  class ResettableEvent: PresentLater, SecretFixture
	construct(linkOb?) { if(linkOb) linkObj = linkOb; }  
	eventOrder = 150
	isActive = nil
	createType() { if(ID) ID.eventOrder = eventOrder; }
	ID = nil
	autoLink = true
	linkObj = (lP && autoLink ? (lP.oK(ActorState) ? lP.gA : lP) : nil)	lo = (linkObj)	//auto-sense connect to lexicalParent if one
	sense = sight
	ct = 0
	interval = 1
	start(trigger?) { if(ID) reset(nil); createType(); isActive = true; startEffects(trigger); }
	startEffects(trigger) {  }
	reset(showMsg = true) { if(ID) { resetEffects(showMsg); ID.removeEvent(); ID = nil; } 
		ct = 0; isActive = nil; }
	events_ { ++ct; events(); }
	events() {  }
	resetMsg = ""
	resetEffects(showMsg) { if(showMsg) resetMsg; }
	valToSymbol { return inh + ' ' + linkObj.valToSymbol; }
	;

  class RDaemon: ResettableEvent
	createType { if(linkObj) ID = new SenseDaemon(self, &events_, interval, linkObj, sense); 
		else ID = new Daemon(self, &events_, interval); inherited; }	;
  class RFuse: ResettableEvent
	createType { if(linkObj) ID = new SenseFuse(self, &events_, interval, linkObj, sense); 
		else ID = new Fuse(self, &events_, interval); inherited; }	;
  class RRealTimeDaemon: ResettableEvent
	createType { if(linkObj) ID = new RealTimeSenseDaemon(self, &events_, interval, linkObj, sense); 
		else ID = new RealTimeDaemon(self, &events_, interval); inherited; }	;
  class RRealTimeFuse: ResettableEvent
	createType { if(linkObj) ID = new RealTimeSenseFuse(self, &events_, interval, linkObj, sense); 
		else ID = new RealTimeFuse(self, &events_, interval); inherited; }	;

  class DryingDmn: RDaemon
  	events { if(ct==lo.dryingMsgCt && (lo.isIn(gpc) && !neverAnnounceDry||lo.announceDry)) say(lo.dryingMsg); 
  		else if(ct>=lo.driedAtCt) { if(lo.isIn(gpc) && !neverAnnounceDry||lo.announceDry) say(lo.driedMsg); 
			lo.makeDry(); 
			reset; }}
	startEffects(t?) { travelManager.activeDryDmns.append(self); }
	resetEffects(m) { inh(m); travelManager.activeDryDmns.rem(self); }	;
  		
;//===========================================================================================================

modify BasicLocation
	roomDesc { if(libGlobal.fullDescMode || !descCt || descCt && !(descCt % 7)) 	desc;
		else conciseDesc; 
		++descCt; }
	conciseDesc = desc
	descCt = 0
	noPQHere = nil
	onlyUseGorPQ = nil
	pqOdds = pD(&pqList) && pqList.eventList.iW({f:(f.oK(GTT1) || f.oK(ELI1)) && !f.isDone}) ? prince.gttOdds : prince.ttOdds
	noAtmIfPQ = nil
	inclGenAtmos = nil
	hasGrass = inclGenAtmos
	kickFallLoc = self
	vCtObjs = nil
	addVCtObj(obj) { if(!vCtObjs) vCtObjs = new Vector(10);
		vCtObjs.app(obj); }
	resetVCts() { if(vCtObjs && vCtObjs.length) 
		foreach(local obj in vCtObjs) {
			local tab = obj.vCtTable;
			tab.forEachAssoc({k,v:tab.removeElement(k)});	}  
		stopMsgFilter.vTable.forEachAssoc({k,v:stopMsgFilter.vTable.removeElement(k)});	}	
    travelerLeaving(traveler, dest, connector)
    	{ if (dest != traveler.location)
            traveler.describeDeparture(dest, connector);
		if(tPC) resetVCts(); 			//
    	leavingRoom(traveler); 
    	plantVCt = 0; }										//
    travelerArriving(traveler, origin, connector, backConnector) {
    	foreach (local actor in traveler.getTravelerMotiveActors) {
        	if (actor.posture != defaultPosture) actor.makePosture(defaultPosture); }
        if(tPC) { "<.p>";	 
			enteringRoomClass(traveler);			//
        	"<.p>"; enteringRoom(traveler); 
			visited = true; }					//
        else { "<.p>"; enteringRoomNPC(traveler); }		//
        traveler.describeArrival(origin, backConnector); }
    enteringRoomClass(traveler) { }
    enteringRoomNPC(traveler) { }
	visited = nil	//* bc seen is set from remote locations (animalYard)
    cannotGoThatWay() { reportFailure(cannotGoThatWayMsg); }	// * show exits removed
    	// * * override fishHere on any water body loc that shouldn't yield fish
	rthrFishCt = 0
    fishHere(waterBody?) { 
		if(pD(&nFishHere,PDD)) fC(nFishHere);
		if(waterBody && waterBody.pD(&nFishIn,PDD)) fC(waterBody.nFishIn);
		if(hook.cts.iW({x:x is in( grubs/*,worms*/ )}) &&  //cheese
				(!caughtFish.discovered || caughtFish.unreachable) 
				&& ( glob.slideshowMode ? ++BasicLocation.rthrFishCt==3 : !rand(waterBody.biteProbability) || BasicLocation.rthrFishCt > 4 ) ) { 
			//adding worms if grubs lost?
    		caughtFish.caught(waterBody); 
			BasicLocation.rthrFishCt = 0;
			waterBody.catchFishDesc(); }
    	else { waterBody.noBiteDesc; ++BasicLocation.rthrFishCt; }
    	waterBody.beenFished = true; }
    	//Eventually you determine that if there are any fish in there, they\'re either not hungry or your bait does not suit their palates. 
    //-fishing: 'you feel a nibble', needs 'set hook/pull pole/jerk/catch (fish) etc.'
    nFishHere = 'There isn\'t anywhere to go fishing where you presently are. '
	#define IFCC local l = location; if(l) while(l.oK(ComplexContainer)) l = l.location; if(l!=nil) l
    yellHere() { IFCC.yellHere();
    	else "You let out a lusty holler. "; }
    jumpHere() { IFCC.jumpHere();
    	else "<<if !gR('enviable')>>You exercise your enviable physical prowess by making a grand leap into the air. <.tr enviable75><<else>><<one of>>You spring<<or>>You leap<<or>>You jump<<or>>You take a leap<<shuffled>> <<one of>>into the air<<or>>up as high as you can go<<shuffled>>. "; }
    jumpOffHere() { if(location!=nil) rA(JumpOff,self);
    	else fC('You might specify what it is you\'re trying to jump off. '); }
    knockHere() { IFCC.knockHere(); 
    	else { local obj = gac.connectionTable.keysToList.valW({x:x.oK(Door)});
			if(obj==nil || !gac.canTouch(obj)) "Are we knocking on air?"; 
			else rA(KnockOn, obj); } }
    swimHere() { 
		local nr = gpc.isInKind(NestedRoom);
		local obj = gac.connectionTable.keysToList.valW(
			{x:(x.oK(WaterBody) || x.swimLogical) && (gac.canTouch(x) || nr && nr.canTouch(x)) && x.sightCond});
		if(!obj) fC(nSwimHere); 
		else if(gpc.isIn(obj)) fC(obj.alreadySwimmingInMsg); 
		else rA(SwimIn, obj); }
	nSwimHere = 'There\'s no water that {you/he} can swim in right now. '
	nSwimDir = 'Are we trying to swim on the ground now, or what? '
	canSwimDir = nil
    digHere(tool?) { IFCC.digHere(tool);
    	else { "You find the softest spot of earth in the area and dig a small hole<<tool ? ' with <<tool.tN>>' : ''>> there. ";
    	findBait();
    	"Afterward, you fill the hole back up and tamp it down. "; } }
    //nDigHere
    findBait(noLuckMsg='You don\'t find anything interesting, however. ') { 
		if(grubs.found && (!grubs.discovered || grubs.unreachable)) { 
			grubs.discover; 
			grubs.mIFT(gac); 
			grubs.takenOn = dayCt;
			grubs.dieDmn.start;
			"Some grubs happen to be residing in this hole, so you take them along with you. <<if gR('predictgrubs')>><<ftm>>Prince Quisborne looks gratified that his prediction was correct. "; }	
			//worms mP (no impl take), msg
		else if(!ccBehindBarn.seen && oneHas(fishingPole))
			"<<one of>>Unfortunately, there\'s nothing in your hole that you could use for bait. Maybe try digging in a different location? 
			<<or>><<oo>>You're having really bad luck trying to find bait. <<oo>>If only you could find a dungheap somewhere, you\'d be sure<<or>>Maybe if you found a dungheap you\'d be able<<cycling>> to garner some squishy crawling things. 
			<<or>>Still nothing bait-worthy in the hole... <<or>>Still nothing bait-worthy in the hole... <<cycling>><<stopping>>";
		else if(!ccBehindBarn.seen)
			"<<one of>>The spot you chose doesn\'t yield anything more significant than dirt. 
			<<or>>You don\'t find anything in the hole that creeps or crawls. 
			<<or>>There are no coins, or arrowheads, or even creepy-crawlies to be seen... if creepy-crawlies are what you\'re after, maybe you could find a dungheap somewhere. 
			<<or>>Again, you find nothing interesting... <<stopping>>";
    	else "<<noLuckMsg>>"; }	//allow find arrowheads?
    plantVCt = 0
    allowPlant = oK(OutdoorRoom) && !overrides(self,BasicLocation,&nPlantHere)
    nPlantHere = 'This doesn\'t seem like a promising spot to be planting anything... '
    dontPlant = 'One moment: you\'ve gone through this much trouble to get a hold of a magic bean, you\'ve had a phantom from another world tell you that it requires a special planting location to be of any use, and you want to plant it here?! '
    allowPour = true
    nPourHere = 'It isn\'t very decent to be dumping liquids out indoors. '
  	kPourOut = 'You find the best place to dispose of the <<gDobj.liquidName>> and dump it out. '
    coughHere() { IFCC.coughHere(); else "You clear your throat with a little cough. "; }
    playHere() { IFCC.playHere(); else if(gSwimming) "Currently, you\'re swimming. "; 
    	else "<<tpr>><<one of>>You carry on a guessing game with Prince Quisborne whenever there\'s a lull in the action. <<or>>You challenge the prince to a contest of \"thumb wars.\" <<or>><<if gpc.isIn(horse)>>You\'d probably tussle with the prince, if you weren\'t mounted on a horse. <<else>>You grapple <<pqs>> and wrestle playfully for a moment. <<end>><<shuffled>><<else>>You\'ve got better things to do at the moment. "; } //stick wrestling, but need stick
    smileHere() { IFCC.smileHere(); else "Putting a smile on your face seems to brighten your mood a little. "; }
    singHere() { IFCC.singHere(); // if something intense happens, set no sing fuse; check for here;
    	else if(gSwimming) fC('Singing while swimming is just kind of strange. ');
    	else "<<tpr>>Your singing voice really isn\'t anything to be ashamed of, and you give the prince a serenade of some of your favorite old tunes. <<else>>You softly sing to yourself, and feel the better for it. "; }	//also can add song titles from festival
	playFluteHere() { IFCC.playFluteHere();
		else if(gSwimming) "Currently, you\'re swimming. "; 
		else "<<if !gR('triedWhistle')>>It doesn\'t take you long to figure out the fingering for a few notes on <<whistle.tN>>. Soon you\'re playing a simple tune. <.r triedWhistle><<else>><<one of>>You whip out <<whistle.tN>> and play some simple tunes. <<or>>With the limited notes at your disposal, you do your best to toot a sweet tune on the bamboo whistle. <<shuffled>>"; }
    danceHere() { IFCC.danceHere(); else if(gSwimming) fC('Even if you felt like dancing, you\'d want to consider getting out of water first. ');
		else if(prince.tense) fC('The situation is a little on the tense side for disporting yourself with dance. ');
		else if(gR('bustmove')) prince.bustMove;
    	else fC('You do love dancing, but you feel self-conscious about simply breaking into dance when there\'s no other dancing going on. '); }
    sleepHere() { IFCC.sleepHere(); else if(gSwimming) fC('Swimming and sleeping aren\'t a healthy combination. ');
    	else fC('You can wait till nightfall for that. '); }
    	// allow handling of? Uzumbung have to sleep till daylight ?
    ;
	#undef IFCC
// * defaultSky modified in managers.t *
modify defaultGround
	vW = 'clay earth soil dirt mud ground/floor'  /// beneficial or problematic?
	dF(DigWith) pTvca local loc = gac.location;
		if(loc.propDefined(&nDigHere)) fC(loc.nDigHere);
		else if(overrides(loc,BasicLocation,&digHere)) loc.digHere(gIobj);
		else if(goR.propDefined(&nDigHere)) fC(goR.nDigHere);
		else goR.digHere(gIobj); } }
	iF(PlantIn) pTv dSelf('plant','planting','in'); } Ch } }
	iF(PutIn) mrT(gDobj && gDobj!=javelin,PlantIn,DirectObject,self)
	dF(Enter) pTvca fC('Enter the ground? '); }}	//* just to allow 'push raft onto the ground'
	tooDistantMsg = 'You can\'t do that right now. '
	;
modify defaultFloor
	dF(Dig) pTvca askForIobj(DigWith);} }
	dF(DigWith) {V if(gor.pD(&digHere)) logical;
		else if(Gor.pD(&nDigHere) && Gor.nDigHere!=nil) IL(loc.nDigHere);
		else IL('This doesn\'t seem like a prime place to be digging. '); }
		CA gor.digHere(gIobj); } }
	;
modify DefaultWall 	dF(All) {V inherited; logicalRank(70, 'defaultobj'); } } ;
modify Floor	vW = 'floor/ground'
	    roomActorStatus(actor) { if (actor.posture not in (standing,swimming)) gLibMessages.actorInRoomStatus(actor, self); }
	iF(TakeFrom) mrT(gDobj && gDobj.isDirectlyIn(goR),Take,DirectObject)
	dF(JumpOn) { remap = gpc.isDirectlyIn(location) ? [JumpAction] : [JumpOffIAction] }
	nDig { local loc = Gor; 
		if(loc.propDefined(&nDigHere) && loc.nDigHere) return loc.nDigHere;
		else return 'This doesn\'t seem like a prime place to be digging. '; }
	verifyEntry(newPosture, alreadyMsg) {
        if (gActor.posture == newPosture
            && isActorOnFloor(gActor)
            && gAction.verifiedOkay.indexOf(self) == nil)
        { illogicalNow(alreadyMsg); }
        else { logicalRank(105, 'on floor');   //*
            gAction.verifiedOkay += self;
        }    }		
;	
modify Room	
	vW = '(my) (this) area room location -'
	roomDaemon { if(noAtmIfPQ && prince.firedThisTurn) return; else inh; }
	cRoomParts = nil
	ceilingStr = 'ceiling'  // * * for releasing balloon in various locs. context should always end with 'the <<ceilingStr>>'
	suppressAnnounceAmbig = true
	// rcvThrow = true              still saying 'hits, and falls to ground'
	// getHitFallDestination(proj,path) { return self; }
	tooFarDConn(obj,acRoom) { return obj.stdTooFar; }
	dF(Default) vI('There won\'t be much need for referring to a room or an area as a whole. You should always be able to accomplish what you need to by speaking in terms of the parts or objects around you. ');}}
	iF(Default) vI('There won\'t be much need for referring to a room or an area as a whole. You should always be able to accomplish what you need to by speaking in terms of the parts or objects around you. ');}}
	mapINH(TravelVia,Examine,LookIn,StandOn,SitOn,LieOn,GetOutOf,Enter,Board,Smell,ListenTo)
	mapINHI(ThrowAt)
	throwHitFallMsg = '<<gDobj.TN>> land<<gDobj.isPlural ? '':'s'>> in <<tN>>. '
	iF(PutIn) rT(Drop,DirectObject)
	iF(PutOn) aiF(PutIn)
	iF(MoveTo) aiF(PutIn) 
	dF(Cross) vI('Instead, try traveling in a direction. '); }}
#ifdef __DEBUG
mapINH(Gonear)
#endif
	;
modify NestedRoom			//Openable Booths may unintentionally override tryImplRemoveObstr: see Pen
	checkTouchViaPath(obj, dest, op) { if (op == PathTo)
        { if (!canObjReachSelf(obj)) return new CheckStatusFailure(cannotReachFromOutsideMsg(dest), dest); }
        else if (op == PathIn)
        { if (!cORCD(obj,dest))  return new CheckStatusFailure(cannotReachFromOutsideMsg(dest), dest); }
        else if (op == PathOut)
        { local ok;  if (dest == self) ok = canReachSelfFromInside(obj);
            else ok = canReachFromInside(obj, dest);
          if (!ok) return new CheckStatusFailure(cannotReachFromInsideMsg(dest), dest); }
        return checkStatusSuccess; }
	cannotReachFromOutsideMsg(dest) { return nReach; }
	nReach = '\^<<tN>> is out of your reach. ' 
	cORCD(obj,dest) { return canObjReachContents(obj); }	
	cORC { return reachCond; }
	reachCond = true 
	pFollow = nil
	effectiveFollowLocation = (pFollow ? self : location)
    canObjReachSelf(obj) { return canObjReachContents(obj); }
	cannotReachFromInsideMsg(dest) {
        	return 'You can\'t reach ' + dest.theName + ' from ' + theName + '. '; }
	canReachFromInside(obj, dest) { 
		return (obj.oK(Actor) ? posturesToReach.iO(obj.posture) : true) && (!restrictedReach || reachObjs.iW({x: dest.isOrIsIn(x)}) 
			|| reachNotCts.iO(dest) || (oK(ComComp) && dest==location)); }	// * final clause for ComplexContainers *
	canReachSelfFromInside(obj) { return true; }
	tryImplicitRemoveObstructor(sense,obj) { if(propDefined(&tIRO) && tIRO(sense,obj)) return true;
		else if(gac.isIn(self) && restrictedReach && (!reachObjs.iW({x: obj.isOrIsIn(x)}) 
				&& !reachNotCts.iO(obj) && !(oK(ComComp) && obj==location))
				&& autoOut(obj)) 
			return tryRemovingFromNested(); 
		else if(gac.isIn(self) && !posturesToReach.iO(gac.posture)) return tryImplicitAction(Stand); 
		else return nil; }	
	//tIRO(sense,obj) { }
	restrictedReach = true
	posturesToReach = [standing]
	reachObjs = []
	reachNotCts = []
	autoOut(obj) { return true; } //* automatically get out of room to touch this obj
	out = nestedRoomOut2
	nGo = Gor.nGo	/////// * CHECK: before, you could dirtravel from a nested room but if the dirprop wasn't defined on the Gor, it would not use the Gor nGo
	actionDobjGetOutOf { local rep = nil; local ed = exitDestination;
		if(ed && ed.oK(WaterBody) && ed.leaveInv && !act.isImplicit) rep = gac.depositInventory(self); 
		gActor.travelWithin(exitDestination);
		gActor.makePosture(gActor.location.defaultPosture);
		if(gac!=prince) defaultReport(&okayNotStandingOnMsg);  //* see next comment
		if(rep && rep[1]) gpc.depositInvMsg(rep);	}
	nGoNear { return gac.isIn(self) ? 'An interesting request, given you\'re already <<actorInName>>. ' : inherited; }
	;	
nestedRoomOut2: TravelConnector  dobjFor(TravelVia) pvca rA(GetOutOf,gac.location); } } 
	;
modify BasicChair
	verifyEntry(posture, alreadyMsg, noRoomMsg) {
        if (allowedPostures.indexOf(posture) == nil)
            return true;
        if (obviousPostures.indexOf(posture) == nil)
            nonObvious;
        if (gActor.posture == posture && gActor.isDirectlyIn(self)
            && gAction.verifiedOkay.indexOf(self) == nil)
            illogicalNow(alreadyMsg);
        else
            gAction.verifiedOkay += self;
        if (!gActor.isIn(self)
            && getBulkWithin() + gActor.getBulk() > bulkCapacity)
            illogicalNow(noRoomMsg);
        if (isIn(gActor))
            illogicalNow(&cannotEnterHeldMsg);
        if (gActor.isDirectlyIn(self) && gActor.posture != posture)
            logicalRank(120, 'already in');
		logicalRank(120,''); //*
        return nil;		}
	performEntry(posture) { local moving = (!gac.isIn(self)); 
		if(moving) gac.travelWithin(self);
		gac.makePosture(posture);
		beenIn = true; 
		if(posture==standing) beenStoodOn = true;
		else if(posture==sitting) beenSatOn = true; 
		if(moving && gac!=prince) defaultReport(kOn);
		else if(gac!=prince) defaultReport(&roomOkayPostureChangeMsg,posture,self); }
	//* ^ ^ this code is brittle: just wanted to prevent prince entry msgs from showing before pc's. but changes will have to be made if prince does any autonomous entry of nrooms
	jumpHere { if(oK(BasicPlatform) && isLow) inh;
		else rA(JumpOff,self); }
	dF(JumpOff) { preCond = [new ObjectPreCondition(self,actorDirectlyInRoom)]
		V if(!gac.isIn(self)) ILN('You\'re not even <<actorInPrep>> <<itObj>>! '); }
		Ac say(kJumpOff); nestedAction(GetOutOf,self); } }
	dF(ClimbDown) adF(GetOutOf)
	dF(JumpOn) { preCond = gac.isIn(self) ? [] : preCondDobjStandOn + objNotHeld
		V if(overrides(self,Thing,&nJumpOn)) IL(nJumpOn); 
			else if(!gac.isIn(self)) verifyDobjStandOn; } 
		Ch if(!gac.isIn(self)) checkDobjStandOn; }
		Ac if(!gac.isIn(self)) { "<<kJumpOn>>"; performEntry(standing); } 
			else jumpHere; } }
	mapdF(Board,Enter,Climb)
	down = perInstance(new DownConn(self))
	eFL = Gor
	beenStoodOn = nil 
	beenSatOn = nil
	beenIn = nil
	rOPCM = '{You/he} <<STAND>>stand<<else SIT>>sit down<<else LIE>>lie down<<end>> <<actorInPrep>> <<tN>>. '
	kOn = '{You\'re} now <<posturing>> <<actorInPrep>> <<tN>>. '
	kJumpOn = 'You make a leap <<actorIntoPrep>> <<tN>>. '
	kJumpOff = 'You spring <<actorOutOfPrep>> <<tN>> through the air and <<exitDestination.getNominalActorContainer(exitDestination.defaultPosture).actorIntoPrep>> <<exitDestination.getNominalActorContainer(exitDestination.defaultPosture).tN>>. '
	showPCSD = nil
	;
  class DownConn: TravelConnector 
  	construct(orig) { obj_ = orig; }
  	getDestination(origin,traveler) { return obj_.exitDestination; } 
  	obj_ = nil
	dF(TravelVia) {Ac if(gac.isIn(obj_)) rA(GetOutOf,obj_); }} 
	isConnectorListed = nil
	;
modify BasicPlatform
	down = perInstance(new DownConn(self))
	isLow = nil		;
modify Platform
	mapdF(Board,Enter,Climb)	;
modify Chair 	
	dF(Use) rT(SitOn,self)
	nLieOn = 'That would just involve doing a very uncomfortable back bend. '	//benches, couches?
	bulkCapacity = 250
	dF(SitOn) {V LR(150,'chair'); inh; } }
	down = chairDownConn
	 ;
chairDownConn: TravelConnector
	dF(TravelVia) pvca rA(Stand);}}
	isConnectorListed = nil
	;
modify Bed		
	dF(Use) rT(LieOn,self)
	defaultPosture = standing
	obviousPostures = [sitting,standing,lying] ;
modify Booth	dF(LookIn) {V inherited Container; } Ch inherited Container; } Ac inherited Container; } } ;

modify TravelConnector
	travelMemory = nil	
	traversed = nil
	pFollow = true
	forceList = nil
	pcTraverseCt = 0
	nT { notifyTravelManager(traveler); 
		if(tPC) { traversed = true;
			++pcTraverseCt; }  }
	notifyTravelManager(traveler) { }	;
	
 	// auto-space/indent travelDescs
modify TravelWithMessage
	nT { inherited TravelConnector(traveler); }
	notifyTravelManager(traveler) { "<.p>"; showTravelDesc; }
;
modify DeadEndConnector
	pFollow = nil	//okay?
	isCircularPassage = true	;	// so they don't show up on exitLister before traveled

modify ThroughPassage
	dF(LookBehind) adF(LookThrough)	;	
modify PathPassage
	dF(Take) mrT(act.getEnteredVerbPhrase == 'take (dobj)',Follow, self)	;
	
modify UnlistedProxyConnector forceList = nil ;

modify Door		//make Hanger if open?
	vW = 'door*doors' 	name = 'door'
	literalDoor = true
	remapDoor = true
	nothingThroughPassageMsg = 'You\'re better off trying to go through <<tN>> if you want to see... '
	kKnockOn() { "&lt;knock&gt; &lt;knock&gt;... <.p>There doesn\'t seem to be any answer: hopefully you weren\'t expecting one. "; }
	kKick { fC('There is really no need to try kicking in <<tN>>. '); }
	nLU = 'There isn\'t anything to gain by trying to look under <<tN>>. '
	nPutUnder = 'There isn\'t anything to gain by trying to put things under <<tN>>. '
	dF(Push) pTvc fC('If you want to open or close <<tN>>, just say so... '); } }
	mapDPVC(Push,Pull,Move)
	dF(MoveWith) vI('It\'s easiest just to talk about opening or closing <<tN>>. '); } }
	dF(MoveTo) vI('<<if literalDoor>>You probably aren\'t going to get <<tN>> off <<itPossAdj>> hinges. <<else>>You can\'t remove <<tN>>. '); } }
	nTie = 'You needn\'t tie things to <<tN>>. '
	nLock = 'You don\'t see a way to lock <<tN>>, and you probably don\'t need to worry about it. '
	nUnlock = 'You consider that maybe <<tN>> <<isnt>> even locked. '
	dF(Take) rT(MoveTo,self,gac)
	initializeThing() { inherited; if(!literalDoor) changeVocab(nil,'door',nil,'doors'); }
	beenOpened() { return masterObject.beenOpened_; }
	makeOpen(stat) { inherited(stat); if(stat) masterObject.beenOpened_ = true; }
	traversed() { return masterObject.traversed_; }
	nT { inherited(traveler); 
		if(Has(dart) && dart.isStuck) { dart.baseMoveInto(otherSide); }
		masterObject.traversed_ = true; }  
	beenOpened_ = static masterObject.isOpen_ 
	traversed_ = nil
	horseWontLeave = true
	dartSticks = true
	mapK(Kick,Break)
	checkDobjOpen { if(propDefined(&nOpen) && overrides(self,Thing,&nOpen)) fC(nOpen); inh; }
	checkDobjClose { if(propDefined(&nClose) && overrides(self,Thing,&nClose)) fC(nClose); inh; }
	dF(KnockOn) pTvc if(propDefined(&nKnockOn)) fC(nKnockOn); }
		Ac say(kKnockOn); } }
	dF(LookIn) adF(LookBehind)
	dF(Use) rT(GoThrough, self)
	iF(LeadInto) pvc}}
	;
modify Stairway 
	vW = 'stair/step/stairway/staircase/stairs/steps' name = 'steps' 
	initializeThing() { inherited; if(!literalStair) 
		changeVocab(nil,['stair','step','stairway','stairs','steps']); }
	literalStair = true
	dF(Use) adF(Climb) 
	dF(Take) adF(Climb) 
	dF(StandOn) adF(Climb) 
	dF(Follow) adF(Climb)
	nLieOn = 'Lying on stairs sounds like a punishment. '  ;

modify Direction	dirName = nil ;

replace noTravelIn: NTM "It's unclear what you're trying to go in, if anything. " ;
replace noTravelOut: NTM "There's no plausible way to go \"out\" here. " ;
	noTravelDown2: NTM "There are no openings below you here. " ;
	noTravelUp: NTM "<<if !gR('skyslimit') && goR.oK(OutdoorRoom)>>It turns out the sky is not the limit: roughly <<mStd ? 'three feet is':'ninety centimeters is'>>, then gravity kicks back in. <.tr skyslimit35><<else>>It's unclear what you're trying to go up, if anything. " ;
modify downDirection 	defaultConnector(loc) { return noTravelDown2; } ;
modify upDirection 	defaultConnector(loc) { return noTravelUp; } ;


modify BulkLimiter
	maxSingleBulk = static bulkCapacity
	empty { return cts.countWhich({x:x.isPortable || x.oK(BasicWater)})==0; }
	beenUsed = static (cts.iW({x:x.isPortable}) ? true : nil)
	allowLiqs = nil
	nI { inherited(obj,newCont);
		if(obj.oK(Liquid) && newCont==self) { 
			if(!allowLiqs) fC(nLiqsIn);  }
		beenUsed = true; }
	nR { inh(obj); }
	tooFullMsg = 'There\'s only so much room in <<tN>> to put things. '
	dF(FillWith) vc checkIobjPutIn;
			if((gIobj.oK2([BasicWater,Liquid]) || gIobj.pD(&fillFrom)) && !allowLiqs) fC(nLiqsIn); } 
		//* currently a little awkward. 'fill pumpkin from bowl' gets "you put the bowl in the pumpkin. "
		//? make ifclause to put cts from a cont into me if vpphrase has 'from' instead of 'with'?  don't have any mechanism with std msg for transferring all of the dry contents of one cont to another. 
		Ac //if(gIobj.)
			rA(PutIn,gIobj,self); } }
	makeWet(startDrying?) { if(isPortable && !floats) foreach(local obj in cts) obj.makeWet(startDrying);
		inh(startDrying); }
	kEmpty { if(!cts.iW({x:x.isPortable})) fC('We\'re not sure what you\'re trying to empty out of <<tN>>. ');
		if(cts.valW({x:x.oK(Liquid)})) rA(Pour,self);
		else { foreach(local obj in cts) {
			obj.mI(Gor.getDropDestination(obj,nil)); }
			"You empty <<tN>> of <<itPossAdj>> contents. "; } }
	//perhaps should allow 'pour cont' if it has nonwater cts in it.
	;
modify RestrictedHolder
    canPutIn(obj) { local sub = validContents.subset({x:x.isClass});
		foreach(local cls in sub) if(obj.oK(cls)) return true;
		return validContents.indexOf(obj) != nil; }
;
modify Container
	dF(Search) adF(LookIn)  //should this be on Thing?
	;

modify Surface
	actionDobjLookIn() { delegated Container(); }
	tooFullMsg = 'There\'s only so much room on <<tN>> to put things. '
	inToOn = nil
	iF(PutIn) mrT(inToOn,PutOn,DirectObject,self)
	// rcvThrow = true		set on Thing
	;

modify Underside
	actionDobjLookUnder() { lookUnderDesc; examineInterior; }
	lookUnderDesc = nil
	ctsListed = nil
	initListers() { inherited; initAL(); }
	tooFullMsg = 'There\'s only so much room under <<tN>> to put things. '
	takeFromNotInMessage = &takeFromNotOnMsg
	;
	
modify RearContainer
	actionDobjLookBehind() { lookBehindDesc; examineInterior; }
	lookBehindDesc = nil
	ctsListed = nil
	initListers() { inherited; initAL(); }
	tooFullMsg = 'There\'s only so much room behind <<tN>> to put things. '
	takeFromNotInMessage = &takeFromNotOnMsg
	;
	
modify ComplexContainer		
	examineStatus { inh; if(!oK(PutHoneyOn) && hasHoney) "<.p>There\'s some honey smeared on <<tN>>. "; }
	zap() { stuck(zapCond); 	//*override if RearCont or Unders. objs should be zapped with ComCont
		local lst = [subContainer,subSurface]; if(subRear && subRear.oK(RearSurface)) lst.app(subRear);
		Each(lst) { if(obj) foreach(local cur in obj.cts) if(cur.isPortable) cur.zap(); }
		mIFT(nil);
		if(oK(Wearable)) makeWornBy(nil);  }
	dF(LookIn) { remap { if(subContainer!=nil) return [LookInAction,subContainer];
			else if(subSurface!=nil) return [LookInAction,subSurface];
			else return nil; }}
    dF(Climb) mrT(getNestedRoomDest(ClimbAction) != nil, Climb, getNestedRoomDest(ClimbAction))
    dF(JumpOn) mrT(getNestedRoomDest(JumpOnAction) != nil, JumpOn, getNestedRoomDest(JumpOnAction))
    dF(JumpOff) mrT(getNestedRoomDest(JumpOffAction) != nil, JumpOff, getNestedRoomDest(JumpOffAction))
	dF(GoUnder) mrT(subUnderside!=nil && subUnderside.oK(NestedRoom),Enter,subUnderside)
	// * verbHeres check for location.oK(ComCont) and will call location.location verbHere
    ;

modify Decoration 
	vL = 75
	dF(Take) {V if(overrides(self,Fixture,&nTake)) IL(nTake); else IL(nImp); } }
	mapINH(Feel,Count,Watch,TravelTo) 
	dF(Smell) vI(nImp); }}
	feelDesc = "<<nImp>>"	//Unthing inherits: shouldn't matter if its default always shows 'notHere'
	notImportantMsg = '<<one of>>It\'s doubtful that <<tN>> will play any important role in the course of this adventure. 
		<<or>>\^<<tN>> <<isPlural ? 'are' : 'is'>> not likely to aid you in your quest. 
		<<or>>You might be overestimating the importance of <<tN>>. 
		<<or>>You might consider turning your attention elsewhere. 
		<<or>>You might contemplate shifting your focus to something more significant. 
		<<or>>You\'ll find that there\'s not much meaningful interaction to be had with <<tN>>.
		<<or>>\^<<tN>> <<verbToBe>> <<aName>>, all right. Moving along... <<shuffled>>'		
//-there may be other verbs more applicable to that obj
//<<or>>Trying to <<verbInf>> <<tN>> is not likely to further your cause. 	// risky for incongruous? GoUnder... change verbInf
	verbInf { local ac = act; rexMatch('(.*)/(<alphanum|-|squote>+)(.*)', ac.verbPhrase);
		return rexGroup(1)[3]; }
#ifdef __DEBUG
	mapINH(Gonear,Purloin,SrcName,Locate,MakeKnown,IsKnown,Check,Zap)
	// vL = (gActionIn(Gonear,Purloin,SrcName,Locate,MakeKnown,IsKnown,Check,Zap) ? 60 : inherited)
#endif 
	;
	
modify Distant
	mapINH(Watch,Count,Read,Shoot,Hook,GoNear,TravelTo)
	iF(ThrowAt) vc if(!throwReaches) fC(tooFarThrow); 
		else if(dmgdThrownAt && gDobj.dmgsThrown || overrides(self,Thing,&nThrowAt)) fC(nThrowAt);} }
	iF(ThrowOver) pv dSelf('throw','throwing','over'); 
		else if(!throwReaches) ILN(tooFarThrow); else nkIL(ThrowOver); } }
	nThrowOver = 'There are probably more important things to attempt. '
	dF(ShootWith) { preCond = (inherited) V inherited; } Ch if(!throwReaches) fC(tooFarShoot); } }
	iF(ShootAt) { preCond = (inherited) V inherited; } Ch if(!throwReaches) fC(tooFarShoot); } }
	dF(CastAt) { preCond = (inherited) V inherited; } Ch if(!throwReaches) fC(tooFarCast); } }
	dF(CastAtWith) { preCond = (inherited) V inherited; } Ch if(!throwReaches) fC(tooFarCast); } }
	iF(CastWithAt) { preCond = (inherited) V inherited; } Ch if(!throwReaches) fC(tooFarCast); } }
	dF(HookWith) { preCond = (inherited) V inherited; } Ch if(!throwReaches) fC(tooFarCast); } }
	nGoNear = 'You can either try traveling in a direction towards <<itObj>>, or it might just not be necessary to approach <<itObj>>. '
	throwReaches = nil
	tooFarThrow = tooFar
	tooFarCast = tooFar
	tooFarShoot = 'Your little makeshift blowgun doesn\'t have that kind of range. '
	//'\^<<tN>> is too far away for your throwing arm. '
#ifdef __DEBUG
	mapINH(Gonear,Purloin,SrcName,Locate,MakeKnown,IsKnown,Check,Zap)
#endif
	;

modify Attachable
	zap { inh; foreach(local obj in attObjs) if(obj.attObjs.iO(self)) obj.attObjs = obj.attObjs - self;
		attObjs = []; }
	;
modify Openable
	beenOpened = static (isOpen_ ? true : nil)
	noImplOpenMsg = nil
	makeOpen(stat) { inherited(stat); if(!beenOpened && stat) beenOpened = true; }
	initListers() { inherited; initOL(); }
	;

modify TravelPushable
	dF(MoveWith) {Ch fC('You might just be able to push it. '); } }
  	describeMovePushable(traveler, connector) {
  		if (gActor.isPlayerChar) reportBefore(&okayPushTravelMsg, self); } ;	// * changed from mainReport *

modify OutOfReach 	
	reachCond = nil
	canObjReachContents(obj) { return reachCond; }
	cORCD(obj,dest) { return canObjReachContents(obj); }	
	checkTouchViaPath(obj, dest, op) { if (op == PathTo)
        { if (!canObjReachSelf(obj)) return 
			// gActionIn(ThrowAt,ThrowTo,ThrowOver) && gIobj==self && gDobj.shortRangeThrow ?
			// new CheckStatusFailure(shortRangeThrowMsg) :
			new CheckStatusFailure(cannotReachFromOutsideMsg(dest), dest); }
        else if (op == PathIn)
        { if (!cORCD(obj,dest))  return new CheckStatusFailure(cannotReachFromOutsideMsg(dest), dest); }
        else if (op == PathOut)
        { local ok;  if (dest == self) ok = canReachSelfFromInside(obj);
            else ok = canReachFromInside(obj, dest);
          if (!ok) return new CheckStatusFailure(cannotReachFromInsideMsg(dest), dest); }
        return checkStatusSuccess; }
	cannotReachFromOutsideMsg(dest) { return nReach; }
	// shortRangeThrowMsg { return gDobj.shortRangeThrowMsg; }
	// v v these aren't getting called: still: push headdress into bowl. You can't fit in that!
	// dF(PushTravel) { preCond = [touchObj] 
	// 	V if(!canObjReachContents(gac)) ILN(rank:20,nReach); else inh; } }
	// dF(PushTravelEnter) { preCond = [touchObj] 
	// 	V if(!canObjReachContents(gac)) ILN(rank:20,nReach); else inh; } }
	// dF(PushTravelThrough) { preCond = [touchObj] 
	// 	V if(!canObjReachContents(gac)) ILN(rank:20,nReach); else inh; } }
	// dF(PushTravelClimbUp) { preCond = [touchObj] 
	// 	V if(!canObjReachContents(gac)) ILN(rank:20,nReach); else inh; } }
	// dF(PushTravelClimbDown) { preCond = [touchObj] 
	// 	V if(!canObjReachContents(gac)) ILN(rank:20,nReach); else inh; } }
	// dF(PushTravelGetOutOf) { preCond = [touchObj] 
	// 	V if(!canObjReachContents(gac)) ILN(rank:20,nReach); else inh; } }
	nReach = '<<TN>> <<verbToBe>> out of your reach. ' 		;

modify Unthing
	unObject = nil
	initializeThing { inh;
		if(unObject) { iVW(unObject.vW); 
			name = unObject.name; } }		;

modify Readable 	dF(Read) {Ac inh; beenRead = true; } }  beenRead = nil ;
modify Wearable		dF(Wear) {Ac inh; beenWorn = true; } }   beenWorn = nil
	makeWornBy(actor) { inh(actor); invNote(); } ;

modify Food 	
	dF(Eat) {Ch if(gross=='privy') fC('You rubbed <<thatObj>> all over unsanitary surfaces<<!gpc.isIn(privyLoc) ? ' at the privy':''>>... there\'s no way you\'re eating <<itObj>>. '); } } 
		//Ac modified in verbs.t to include zap and kEat
	dF(RubOn) {Ac if(gIobj is in(privy,privyBench,privyHole)) {
		"What your intentions for doing this are are obscure, but we certainly hope you don\'t plan on ever eating <<thatObj>> after this. "; gross = 'privy'; }
		//else if(gIobj==)	//other dirty
		else inh; }}	
	//TouchWith like Rubs?	
	gross = nil
	;
modify Key	
	driedAtCt = 5	
	dartBounces = true
	tasteDesc = "Metal usually has a distinctively metallic flavor. "
	nDigWith = 'You could technically stab into <<gDobj && gDobj!=self ? gDobj.tN : 'that'>> with a key, but it\'s not going to help you get very far very fast. ' 
	nBurn = '\^<<tN>> won\'t burn, and it would take a whole lot of heat to melt. '
	nFold = '\^<<tN>> will not bend under your force. '
	nBreak = 'Keys of this nature are just about unbreakable. '
	mapN(Break,Cut,Chop,Tear)
	nTurn = 'A key can be used just by unlocking something with it. '
	nPutOnn('A key isn\'t much of a surface for putting things on. ')
	nLI1 nLT1
	soundDesc = "Keys aren\'t normally audible, unless they\'re on a ring with others. "
	nEat = 'That couldn\'t be good for your digestive tract. '
	dF(UseWith) {V verifyIobjLockWith(); }
        preCond() { return preCondIobjLockWith(); }
        remap() { if (gTentativeIobj.length() == 1) {
            if (gTentativeIobj[1].obj_.isLocked) return [UnlockWithAction, OtherObject, self];
                else return [LockWithAction, OtherObject, self]; }
            else return [UnlockWithAction, OtherObject, self]; } } 
    ;

modify Actor
	initializeActor() { inherited; lastLoc = (location); } 
	examineStatus() { 
		if(usePD) postureDesc(); 
		if(newlineBeforeState) ",,,"; 
		cS.stateDesc(); 
		inherited Thing; }
		// * * * a hack because having trouble make 'show me the way' verb work
	obeyCommand(issuingActor, action) 
		{ if(action.oK(LeadWayAction)) { 
			issuingActor.noteConversation(self); 
			return true; }
		return inherited(issuingActor, action); }
	noteConversationFrom(other) { 
		if(other==gpc) conversed = true; 
		inherited(other); }
	sDO = (cS.propDefined(&sDO) ? cS.sDO : inherited)
	newlineBeforeState = (cS.newlineBeforeState)
	usePD = (cS.usePD)
	lastAct = -1
	noteAct() { lastAct = gClock; }
	hasActed() { return lastAct==gClock; }	//* use in conjunction with conversedThisTurn
	conversed = nil		//* ever conversed yet?
	takeTurnWithoutPC = nil
	takeTurnAfterConv = nil
	leadWayAction(topic) { if(isPlayerChar()) 
			"It only makes sense to say something like this to someone else. ,,,[For instance: \"&lt;&gt;&gt; boy, show me the way to the market\"]"; 
		else "\^<<tN>> <<isPlural ? 'are' : 'is'>> not disposed to show you the way to <<Gbm.propDefined(&tN) ? Gbm.tN : gTopicText>>. "; }		//animals
	askNameTE = nil
	maxSingleBulk = static bulkCapacity
	wetness = 0
	lastLoc = (location)
	lastAction = static WaitAction.createActionInstance()
	lastDobj = nil	lastIobj = nil mRecentDobj = nil mRecentIobj = nil
	rememberTravel(origin, dest, backConnector)
		{ lastLoc = origin==ferry ? ferry : origin.Gor;			// changed from origin to origin.Gor
		inherited(origin, dest, backConnector); }
	dF(TalkTo) {Ac inh; if(!gR('talkToTip') && !gR('usedAskOrTell')) "<.p>[In this game, 'talk to [character]' mostly just translates to '[character], hi'. You will get farther trying to 'ask [character] about [something]', 'tell [char] about [something]', 'give [object] to [char]', 'show [obj] to [char]', or 'ask [char] for [obj]'. See the instructions ('instr') for more.] <.r talkToTip>"; } }
	dF(AskAbout) {Ac inh; gReveal('usedAskOrTell'); } }
	dF(TellAbout) {Ac inh; gReveal('usedAskOrTell'); } }
	handleConversation(actor, topic, convType) {
		if (!handleTopic(actor, topic, convType, nil)) {
			if(oK(Person) && convType==askAboutConvType && Gbm && Gbm.propDefined(&askAnswer)) 
				Gbm.askAnswer;
			else if(oK(Person) && convType==tellAboutConvType && Gbm && Gbm.propDefined(&tellAnswer)) 
				Gbm.tellAnswer;
			else if(oK(Person) && convType==askForConvType && Gbm && Gbm.propDefined(&askForAnswer)) 
				Gbm.askForAnswer;
            else defaultConvResponse(actor, topic, convType); }}
	defaultConvResponse(ac,top,typ) { if(propDefined(&all)) "<<all>>"; else inh(ac,top,typ); }
    defaultGreetingResponse(actor) { "<<hi>>"; }
    defaultGoodbyeResponse(actor) { "<<bye>>"; }
    defaultAskResponse(fromActor, topic) { "<<ask>>"; }
    defaultTellResponse(fromActor, topic) { "<<tell>>"; }
    defaultShowResponse(byActor, topic) { "<<show>>"; }
    defaultGiveResponse(byActor, topic) { "<<give>>"; }
    defaultAskForResponse(byActor, obj) { 
		if(self!=prince && oneHas(obj)) "Are you sure you don't already have <<obj.itObj>>? "; 
		else "<<askfor>>"; }
    defaultYesResponse(fromActor) { "There\'s no context currently for a yes or no answer. <<first time>>(And sometimes rhetorical questions are employed...)"; }
    defaultNoResponse(fromActor) { "There\'s no context currently for a yes or no answer. <<first time>>(And sometimes rhetorical questions are employed...)"; }
    defaultCommandResponse(fromActor, topic) { "<<cmd>>"; }
	hi = '<<TN>> return<<isPlural?'':'s'>> the gesture. '
	bye = 'This isn\'t really a situation that warrants a farewell. '
	cmd = 'There is no present need for you to make that request of <<tN>>. '
	askfor = '<<one of>><<ask>>
		<<or>>Sometimes folk don\'t have what you\'re asking for, and sometimes they won\'t give it to you, but in either case it\'s all the same: you don\'t get it.
		<<or>>You decide not to <<rand('tax','trouble','bother')>> <<itObj>> with such a request. <<shuffled>>'
	ask = 'It doesn\'t seem as though your adventure will be furthered by asking that question. '
	tell = 'After telling <<tN>> about <<!Gbm.oK(Topic) ? Gbm.tN : 'that'>>, you get more or less the reaction you might have expected of <<itObj>>. '
	give = '<<TN>> <<verbToBe>> probably not in need of your generosity. '
	show = '<<TN>> exhibits an amount of interest proportionate to being shown <<gDobj.aName>>. '
	rest = 'You decide not to bother <<TN>> over that. '
	//all = ''	
	;

modify Person
	literalPerson = true
	checkTakeFromInventory(actor,obj) { fC('You were brought up to ask for something, not take it, if someone else has it. '); }
	;

modify ActorState
	specialDescListWith() { return (!overrides(self, ActorState, &specialDesc) && !propDefined(&commonDesc)) ?
		gA.actorListWith : []; }
	usePD = true	// * * * use postureDesc for this state?
	//commonDesc = "<<gA.posture.participle>> nearby. "
	stateDesc { if(propDefined(&commonDesc)) "\^<<gA.itIs>> <<commonDesc>>"; 
		else if(propDefined(&commonDescS)) "\^<<gA.itNom>>\'s <<commonDescS>>"; 
		else inherited; }
	sD { if(propDefined(&commonDesc)) "\^<<one of>><<isInitState ? gA.aName : gA.TN>><<or>><<gA.tN>><<stopping>> is <<commonDesc>>"; 
		else if(propDefined(&commonDescS)) "\^<<one of>><<isInitState ? gA.aName : gA.TN>> is<<or>><<gA.tN>>\'s<<stopping>> <<commonDescS>>";
		else inherited; }
	newlineBeforeState = nil
	takeTurnWithoutPC = (gA.takeTurnWithoutPC)
	takeTurnAfterConv = (gA.takeTurnAfterConv)
	maybeTakeTurn(script) { if(!script) return; local actor = gA;
		if(!gpc.canSee(actor)) { if(takeTurnWithoutPC) { script.dS; actor.noteAct; } }	
		else if(takeTurnAfterConv || !actor.conversedThisTurn()) { script.dS; actor.noteAct; } }	
    takeTurn() { local actor = gA;
		if (actor.curConvNode != nil && !actor.conversedThisTurn()
      		&& actor.curConvNode.npcContinueConversation()) { }
		else if(//!actor.takeTurnAfterConv && 
			actor.hasActed) return;			//allow for certain Agendas to execute?
        else if(actor.executeAgenda()) { }
        else if(oK(Script)) maybeTakeTurn(self);					//adds	
		else if(actor.oK(Script)) maybeTakeTurn(actor);	 }			//
	;
	
modify AgendaItem	initiallyActive = true
	setDone() { isDone = true; } ;

modify Action
    afterAction() { gActor.lastAction = gAction;  gac.lastDobj = gDobj; gac.lastIobj = gIobj; inherited;  }
	maybeAnnounceImplicit() { 
		if(gac==prince ||
			gDobj && gDobj.propDefined(&suppressAnnounceImpl) && gDobj.suppressAnnounceImpl.iO(baseActionClass) ||
			gIobj && gIobj.propDefined(&suppressAnnounceImpl) && gIobj.suppressAnnounceImpl.iO(baseActionClass) )
				return nil;
		return inh;	} ;
modify TAction
	askDobjResponseProd = singleNoun
	;
modify TravelAction
	execAction { if(getDirection==upDirection && goR.propDefined(&upRemap)) 
			_replaceAction(gac,goR.upRemap[1],goR.upRemap.removeElementAt(1));
		else inh; } ;

modify DistanceConnector	isListedInContents = nil ;	//* BaseMultiLoc allowed these to show in x remote room

modify SensoryEmanation
	descWithoutSource = (descWithSource)	hereWithoutSource = (hereWithSource) 
	hereWithAsDesc = 0	//* int so I can use template for t/n
	hereWithSource { if(hereWithAsDesc || oK(SimpleNoise) || oK(SimpleOdor)) descWithSource; else ""; }
	displaySchedule { if(!oK(SimpleNoise) && !oK(SimpleOdor))  return [2,2,3,3,4,5,7]; return [nil]; }
	listenDesc = soundHereDesc
	;
modify SimpleNoise
	vW = 'sound sounds noises noise noise'
	soundHereDesc = desc
	listenDesc = desc
	nIntang = 'That doesn\'t seem particularly applicable to sounds. '
	;
modify SimpleOdor	vW = 'scent smell fragrance air' 
	iF(FillWith) {V if(gDobj && gDobj==ball) logical; 
		else IL('We don\'t understand what you\'re trying to do. '); } }	
	nIntang = 'That doesn\'t seem particularly applicable to smells. '
	;
modify roomListenLister
	showListItem(obj, options, pov, infoTab) {
		if(gActionIs(ListenImplicit)) obj.listenDesc; else obj.soundHereDesc(); } ;

modify Topic 	
	vocabLikelihood = 50 
	isKnown = nil
	drawable = nil 
	dF(Purloin) VI('It\'s a topic.')
	dF(Gonear) VI('It\'s a topic. ')
	;
  class KTopic: Topic  isKnown = true ;

modify ThingMatchTopic
    matchTopic(fromActor, obj)
    { if(propDefined(&matchClass) && matchClass) {				//
			if(matchClass.oK(Collection)) {          //not working....
				local res = nil; foreach(local c in matchClass) if(obj.oK(c)) res = true;
				return res ? matchScore : nil;
			} 
        	else if(obj.oK(matchClass)) return matchScore; }			//
        if (matchObj && matchObj.ofKind(Collection))
			{ if (matchObj.indexOf(obj) != nil)
                return matchScore;}
        else { if (matchObj == obj)
                return matchScore;}
        return nil; } ;

modify TopicMatchTopic
    matchTopic(fromActor, topic) { 
		if (matchObj != nil) { 
			if (matchObj.ofKind(Collection)) {
                if (matchObj.indexWhich({x: findMatchObj(x, topic)}) != nil)
                    return matchScore; }
            else { if(findMatchObj(matchObj, topic)) return matchScore; } }
        if(propDefined(&matchClass) && matchClass) {				//
        	if(topic!=nil && topic.oK(ResolvedTopic) && topic.getBestMatch && topic.getBestMatch.oK(matchClass)) 
				return matchScore; }	 //
        if (matchPattern != nil && topic.canMatchLiterally()){
            local txt;
            txt = topic.getTopicText();
            if (!matchExactCase)
                txt = txt.toLower();
            if (rexMatch(matchPattern, txt) != nil)
                return matchScore;}
        return nil;}  ;

modify TopicEntry
    handleTopic(fromActor, topic) { noteInvocation(fromActor);
        setTopicPronouns(fromActor, topic);
		if(!self.oK(AltTopic) && location.oK(TopicEntry)) {							//
			if(location.oK(Script) && overrides(location,EventList,&eventList)) { location.doScript(); }   //
        	else location.topicResponse;		}												//
        else if(oK(Script) && overrides(self,EventList,&eventList)) { doScript(); }   //
        else topicResponse; }
	realm = Thing.realm
	PC = Thing.PC
;
modify DefaultTopic
	deferToEntry(other)  { return !other.oK(DefaultTopic); }
;
modify CollectiveGroup
	isCollectiveAction(action,whichObj) { return actions && actions.iW({f:action.oK(f)}); }
	actions = [ExamineAction]  ;

//modify ObjOpenCondition				// for library door exterior

modify CommandReport
	construct() { inh;
		if(libGlobal.cmdRepDobj && gDobj && gDobj!=nil) dobj_ = gDobj; }
	dobj_ = nil  ;
modify libGlobal cmdRepDobj = nil ;

modify conversationManager
	patStr = R'<Alpha>+'
	patDigit = R'<Digit>+'
	customTags = 'r|ur|tr|pq'
	doCustomTag(tag,arg) { 
		if(tag=='r') setRevealed(arg);
		else if(tag=='ur') revealedNameTab[arg] = nil;
		else if(tag=='tr') { 
			local str = rexSearch(patStr,arg)[3];
			local delay = rexSearch(patDigit,arg)[3];
			setRevealed(str);
			pendingUnreveals.app([str,uRDmn.ct + Int(delay)]); }
		else if(tag=='pq') {
			setRevealed('pqsusp');
			pendingUnreveals.app(['pqsusp',0]);	}	 }
	uRDmn: RDaemon { events { 
		if(lo.pendingUnreveals.length==0) return; 
		foreach(local cur in lo.pendingUnreveals) { 
			if(cur[2]<=ct) { 
				lo.revealedNameTab[cur[1]] = nil; 
				lo.pendingUnreveals.removeElement(cur); } } } }
	pendingUnreveals = static new Vector(6)	 ;
InitObject execute { conversationManager.uRDmn.start; } ;
		
modify Tip shown = self not in(footnotesTip,oopsTip,sailTip) ? true : nil ;
	
modify TadsObject
#ifdef __DEBUG
	sourceName = perInstance(srcName(self)) 
#endif
	oK2(lst) { 
		if(!lst.oK(Collection)) return ofKind(lst);
		foreach(local cls in lst) if(ofKind(cls)) return true;
		// for(local i in 1..argcount) {
		// 	if(ofKind(getArg(i))) return true; }
		return nil; }
	;
modify String
    allToTitleCase() { local str = self;
        str = str.substr(1, 1).toTitleCase() + str.substr(2, str.length);
        local i = 0;
        while ((i = str.find(' ', i + 1)) && i < str.length) {
            str = str.substr(1, i) + str.substr(i + 1, 1).toTitleCase() + str.substr(i + 2);  }
        return str;  }
    ending() { return substr(-1); }
	;

modify List
	strW(func) { foreach(local ele in self) { if(dataType(ele)==TypeSString && func(ele)) return ele; } return nil; }	;

modify Vector
	strW(func) { foreach(local ele in self) { if(dataType(ele)==TypeSString && func(ele)) return ele; } return nil; }
	valToSymbol() { return toList.valToSymbol; }
	;
	
// modify LookupTable
// 	valToSymbol { forEachAssoc({k,v:"\n<<vTS(k)>> -> <<vTS(v)>>\n"}); return ''; }
// 	;	//clogs up stack traces
	
modify inputManager
	pauseForMore(rt) { if(glob.suspPause) return; else inh(rt); }  //To bypass Pauses in captureOutput
	// getInputLine(rt,pfunc) {
	// 	local ret = inh(rt,pfunc); 
	// 	if(dataType(ret)==TypeSString) { "GHK"; return 'ghk'; }
	// 	else return ret;
	// }
	;
// modify aioInputEvent(timeout)
// {
//    ":LK";
//    local ret = inputEvent(timeout);
//    if(!ret[2].find(R'<AlphaNum>')) "BLANK"; 
//    dp(ret)
//     return ret;
// }
// modify aioInputLineTimeout(timeout)
// {
//    local ret = inputLineTimeout(timeout);
//     return [ret[1],'lkj'];
// }
modify libGlobal 
	invwinOn = true
	allowNightColors = true
	nightColors = nil
	nightColorStr = '<body bgcolor=141418 text=45d848>'
	borderVal = 1
	suspPause = nil
	fullDescMode = nil
	slideshowMode = nil
	difficultyMode = normal
	traditionalMode = nil
	srMode = nil
	compBuild = nil
	measureType = standard 
	testing = nil 
	debugIntro = nil
	typeOutOn = nil 
	gTSave = nil
	noMatchKnown = nil
	nonObviousTable = static new LookupTable()
	suspendUndoSave = nil
	tentativeStuck = nil
	drawSurface = nil
	leavesWereDry = nil
	disambigOrAskMode = nil
	lastCmdStr = ''
	_shcstr = 'li'
	showShortcutTip { switch(_shcstr) {
		case 'li': "<.p>[If you wish, you can abbreviate 'look in' to 'li'. Similarly, 'look behind', 'look under', and 'look through' can be abbreviated to 'lb', 'lu', and 'lt' respectively.]"; break;
		case 'lb': "<.p>[If you wish, you can abbreviate 'look behind' to 'lb'. Similarly, 'look in', 'look under', and 'look through' can be abbreviated to 'li', 'lu', and 'lt' respectively.]"; break;
		case 'lu': "<.p>[If you wish, you can abbreviate 'look under' to 'lu'. Similarly, 'look behind', 'look in', and 'look through' can be abbreviated to 'lb', 'li', and 'lt' respectively.]"; break;
		case 'lt': "<.p>[If you wish, you can abbreviate 'look through' to 'lt'. Similarly, 'look behind', 'look under', and 'look in' can be abbreviated to 'lb', 'lu', and 'li' respectively.]"; break;
		} }
	showAskTellTip {
		"<.p>[If you have already begun a conversation with someone, you can simplify 'ask character about something' to 'a something'. Likewise, 'tell char about something' can be entered as 't something'. <<oo>>,,,Example: ,,,>guide, hello ,,,>a himself ,,,>a forest ,,,>t me ] <<or>><<or>><.r finishedAskTip><<stp>>";	}
	showSearchTip {
		"<.p>[Just to be clear: 'search' and 'look in' are synonymous in this game. 'search' can be abbreviated to 'c', and 'look in' can be shortened to 'li'. They should both do the same thing.] ";	}
	showEganTip = "<.p>[Just to avoid confusion: 't person' does not stand for 'talk to person'. It is short for 'tell (whomever you\'re talking to) about person'. As you were...] "
	forceTypewriter = nil  //still less than desirable issues if turned on
	//* allDirItems, cmdRepDobj
	;
enum normal, harder ;

notifyShortcut(which) {
	if(glob.slideshowMode) return; 
	if(which is in('askabout','tellabout')) {
		if(gR('finishedAskTip')) return;
		gReveal('askTellShortcut');
		extRep('<.tr askTellShortcut600>');	
		new OneTimePromptDaemon(libGlobal,&showAskTellTip);	}
	else if(which=='c') {
		gReveal('searchTip');		// the gReveals prevent ComConts from sending two notices
		extRep('<.tr searchTip600>');
		new OneTimePromptDaemon(libGlobal,&showSearchTip);	}
	else if(which=='egan') {
		gReveal('eganWarning');
		new OneTimePromptDaemon(libGlobal,&showEganTip);
	}
	else {
		if(!(act.getEnteredVerbPhrase.find('look'))) return;
		gReveal('shortcuts');
		extRep('<.tr shortcuts600>');
		libGlobal._shcstr = which;
		new OneTimePromptDaemon(libGlobal,&showShortcutTip); }
}	

  //---------------------------------------------------------------------------------------------------------
modify Thing
				/*  OVERRIDING   */
	vocabLikelihood = 100
	hideFromAll(action) { return !isPortable; }
	adjustLookAroundTable(tab,pov,actor) {
		inherited(tab,pov,actor);
		if(listLoc_ !=  nil) { 
				tab.removeElement(listLoc_[2]);	// removes the senseConn (usu. window) from lookAround
      			local lst = tab.keysToList(); 
      			foreach(local cur in lst) { 
        			if(!cur.isIn(listLoc_[1])) tab.removeElement(cur); } } }
	initializeThing() { if(trueProp) foreach(local p in trueProp) self.(p) = true;
		if(nilProp) foreach(local p in nilProp) self.(p) = nil;
		if(combustibleObjs.iO(self)) combustible = true;
		if(dontBurnObjs.iO(self)) dontBurn = true; 
		if(hookableObjs.iO(self)) hookable = true; 
		inherited; 
		initListers(); 
		origLoc = location; 
		loadPQTopics();
		  //**** this def might take apart a portable comcont if code says Each(portable) mI(newloc)
		if(!pD(&isPortable,PDD)) isPortable = (oK(ComComp) && location.isPortable || !oK(NonPortable) && !oK(CollectiveGroup) && !oK(ActorState)
			&& !oK(TravelConnector) && !oK(Intangible) && !oK(UntakeableThing) && !oK(Topic)); 
		}
	examineStatus { inh; 
		if(!oK(PutHoneyOn) && hasHoney) "<.p>There\'s some honey smeared on <<tN>>. ";
		if(glowing) "<.p><<TN>> is glowing by reason of some phosphorescent slime. "; }
	listName = (me.use2 ? altListName : inherited)
	inRoomName(pov) { return iRNstr; }
	distantThingDesc = "\^<<itIsContraction>> pretty far away for making any noteworthy discoveries. "
	nothingInsideMsg =	//add more var.
        '<<one of>>There{&rsquo;s| was} nothing unusual in {the dobj/him}. 
		<<or>>You search <<tN>>. <<rand('\^<<itIsContraction>>','Your findings are')>> <<one of>>disappointingly<<or>>more or less<<shuffled>> <<one of>>ordinary<<or>>unenlightening<<or>>unrevealing<<shuffled>>. <<shuffled>>'
    nothingUnderMsg = //{ if(isIn(gac)) 'You\'re holding <<itObj>>, so what do you expec
        '<<one of>>{You/he} {sees} nothing unusual under {the dobj/him}. 
		<<or>>You look under <<tN>>. Your findings are <<one of>>disappointingly<<or>>more or less<<shuffled>> <<one of>>ordinary<<or>>unenlightening<<or>>unrevealing<<shuffled>>. <<shuffled>>'
    nothingBehindMsg =
        '<<one of>>{You/he} {sees} nothing unusual behind {the dobj/him}. <<or>>You look behind <<tN>>. Your findings are <<one of>>disappointingly<<or>>more or less<<shuffled>> <<one of>>ordinary<<or>>unenlightening<<or>>unrevealing<<shuffled>>. <<shuffled>>'
    nothingThroughMsg =
        '{You/he} {can} see nothing through {the dobj/him}. '
	lookAroundWithinName(actor, illum) {
        if (illum > 1) { "\^<<(roomnameStyleTag.tCase ? roomName.allToTitleCase : roomName)>>";  }
        else { say(roomnameStyleTag.tCase ? roomDarkName.allToTitleCase : roomDarkName); }
		actor.actorRoomNameStatus(self); }
	canBeSensed(sense,trans,ambient) { 
		if(isIn(artifactCase) && artifactCase.beenOpened && sense not in (smell,touch)) return true;     //still gave "You cannot see that"
		if(sense==sight) return sightCond && inherited(sense,trans,ambient);
		else if(sense==touch) return touchCond && inherited(sense,trans,ambient);
		else return inherited(sense,trans,ambient); }
	canTouch(obj) { if(obj.oK(Distant)) return nil; 
		return obj.touchCond && inh(obj); }
	showSpecialDesc { inh; if(showsCtsInSD) examineListContents; }
	// baseMoveInto has clause added for inventoryWindowDaemon
	sightPresence = (sightCond && inherited)
	allStates = [wetState]
	getState = wet ? wetState : nil
	meetsObjHeld(actor) { return inh(actor) || isIn(basket) && basket.isIn(actor) || isIn(bowl) && bowl.isIn(actor); }
	ofKind(cls) { if(cls.oK(Collection)) 	
			return cls.iW({x:oK(x)});
		else return inh(cls); }		/////// is this override why some things didn't seem to work
	
					/*	CUSTOM DEFS	*/
	iRNstr = '<<actorInName>>'
	doesnt = isPlural ? 'don\'t' : 'doesn\'t'
	isnt = isPlural ? 'aren\'t' : 'isn\'t'
	isInKind(kind) { local loc = location;
    	if(loc == nil) { if(kind==nil) return !isTopLevel;
            else return nil; }
        if(loc.oK(kind) || kind is in(Fire,BasicFire) && loc==deadTree && litter.isLit) return loc;	// instead of true
		return loc.isInKind(kind); }
	isInList(lst) { local loc = location;
    	if(loc==nil) { if(lst==nil) return !isTopLevel;
            else return nil; }
        if(lst.iO(loc)) return true;
		return loc.isInList(lst); }
	isInWhich(func) { local loc = location;
    	if(loc==nil) { if(func==nil) return !isTopLevel;
            else return nil; }
        if(func(loc)) return true;
		return loc.isInWhich(func); }
	isDobj = gDobj && gDobj==self
	isIobj = gIobj && gIobj==self
	vCtTable = nil
	checkVCt(action) { if(!vCtTable) vCtTable = new LookupTable(8,8); return vCtTable[action.baseActionClass]; }
	noteVCt(action) { vCtTable[action.baseActionClass] = true; Gor.addVCtObj(self); }
	altListName = name
	suppressAnnounceRemap = nil
	objName = tN
	TN = '\^<<tN>>'
	sightCond = true
	touchCond = true
	A = 0	B = 0	C = 0	D = 0	
	togCond = nil	tog2Cond = nil
	tog(str,altStr) { if(togCond) return str; else return altStr; }
	tog2(str,altStr) { if(tog2Cond) return str; else return altStr; }
	origLoc = nil
	makeInvalid(str) { local m = method() { if(gActionIn(Take,Drop)) inh; else IL(str); };
		setMethod(&verifyDobjAll,m); 
		setMethod(&verifyIobjAll,m); }
	changeName(newName,makeProper?) { name = newName; 
		if(makeProper) isProperName = true; 
		invNote(); }
	changeVocab(addWords,delNouns?,delAdjs?,delPlurals?) { if(addWords) iVW(addWords);
		if(delNouns) cmdDict.removeWord(self,delNouns,&noun);
		if(delAdjs) cmdDict.removeWord(self,delAdjs,&adjective);		
		if(delPlurals) cmdDict.removeWord(self,delPlurals,&plural);  }
	voc(state) { if(state=='wet') changeVocab('wet damp -');
		else if(state=='dry') changeVocab(nil,nil,['wet','damp']); 
		// could be expanded
		}	//change to ThingState
	listLoc_ = nil
	listRemoteCts(otherLoc,senseCon) { listLoc_ = [otherLoc,senseCon]; 
		try { lookAround(gac,LookListSpecials|LookListPortables); }
		finally { listLoc_ = nil; } }
	loadPQTopics() { 
		if(pD(&pqAsk)) {
			if(propType(&pqAsk)==TypeObject) {
				pqAsk.matchObj = self;
				pqAsk.location = prince;
				prince.addTopic(pqAsk); }
			else { local a = new AskTopic;
				a.matchObj = self;
				a.setMethod(&topicResponse,getMethod(&pqAsk));
				a.location = prince;
				prince.addTopic(a); }
		}
		if(pD(&pqTell)) {
			if(propType(&pqTell)==TypeObject) {
				pqTell.matchObj = self;
				pqTell.location = prince;
				prince.addTopic(pqTell); }
			else { local a = new TellTopic;
				a.matchObj = self;
				a.location = prince;
				a.setMethod(&topicResponse,getMethod(&pqTell));
				prince.addTopic(a); }
		}
		if(pD(&pqAskTell)) {
			if(propType(&pqAskTell)==TypeObject) {
				pqAskTell.matchObj = self;
				pqAskTell.location = prince;
				prince.addTopic(pqAskTell); }
			else { local a = new AskTellTopic;
				a.matchObj = self;
				a.location = prince; 
				a.setMethod(&topicResponse,getMethod(&pqAskTell));
				prince.addTopic(a); }
		}
	}
	nimpVoc(msg,str,str2?) { if(gDobj && gDobj==self) { 
			local gdw = act.getDobjWords;
			if(!gdw) return; //* for when 'all' is used
			if(gdw.iW({x:x.find(str)}))	fC(msg);
			if(str2 && gdw.iW({x:x.find(str2)}))	fC(msg); } }
	zap() {  
		removeHoney;
		foreach(local cur in cts) { if(cur.isPortable) cur.zap(); }
		mIFT(nil);
		stuck(zapCond);  }
	zapCond = defZapCond
	zapMsg(str) { say(str); zap; }
	defZapCond = nil
	trueProp = nil
	nilProp = nil
	pendReclaim = nil
	makeEmpty() { foreach(local obj in cts) if(obj.isPortable) tryImplicitAction(TakeFrom,obj,self); } //fix implmsg; say 'first empty/removing the contents of theobj
	cf(func) { if(func) (func)(); }	// will this work without accounting for args?
	allDeadlyWeapons = [javelin,axe,bar,dart,fork,iron,mattock,(butterKnife.sharpened ? butterKnife : mattock)] // dart,fork****
	/* LIKELY ATTACKWITH IOBJS:
-needle,plank,slate,javelin,axe,iron bar,fishing pole,powder,dart,mattock,pressing iron */ 
	isHeavy = self is in(javelin,axe,bar,mattock,iron,horseshoes,plank,osmium,rollingPin,keg,pumpkin) //saddle,pumpkin
	combustibleObjs = [caughtFish,apron,grubs,honey,fishingPole,handkerchief,cattail,bladNote,strawMat,couchStuffing,dart,bowl2,plank,burlap,marionette,thread,whistle,bean,llamaWool,snakeskin,vines,skyLantern,candle,cork,glove,flyer,cheese,basket,canvas,artifactCase,carrots,deadFish,iceBlock,hardtack,ball,bark,beet,WoodStrip,Peach,Mango,DeadLeaves,horehound,privyPaper,woodShingle,pumpkinSeeds,pumpkin,keg,whittled,scrapWood,knot,sylvFlowers,balloon]
	dontBurnObjs = [apron,fishingPole,handkerchief,dart,plank,burlap,whistle,bean,skyLantern,cork,glove,basket,canvas,artifactCase,deadFish,ball,beet,privyPaper,pumpkin,keg,balloon]
	// remove objs that have a safe zapcond
	hookableObjs = [apron,handkerchief,cattail,strawMat,couchStuffing,burlap,thread,llamaWool,snakeskin,vines,skyLantern,glove,basket,canvas,deadFish,caughtFish,artifact,privyPaper,pipe]

	isPortable = true  		// * init will set based on class *
	seemsPortable = (isPortable)
	putWithoutTake = (isIn(tongs))  // * sometimes want to disable mandatory 'take' before 'put' *
	putInWithoutTake = nil
	alwaysSLE = nil		// * means liD doesn't suppress slE *
	showsCtsInSD = nil
	LIIL = nil 	LUIL = nil	LBIL = nil	// * LookUnder/In/Behind is illogical?
	moveWithObj(obj) { return nil; }
	turnWithObj(obj) { return nil; }
	dontTaste = nil
	glowing = nil
	hangable = nil		//something becomes hangable if cord tied to it?
	kickable = true
	abrasive = nil
	hookable = nil
	disposable = nil	//!zapCond   this wouldn't work for regenerating items... if obj got stuck w panther or garg, zap wouldn't be called. would need special handling in all non-zapping unretrievable locs (privy?)
	isMetal = nil
	makesSmoke = nil
	lowHitFall = nil
	horseTouch = nil
	canJumpOn = isPortable && !dmgdThrownAt && !isIn(gac) && (isDirectlyIn(goR) || location && location.oK(BasicPlatform) && location.isLow) 
	 rcvThrow = oK(Surface) && !oK(Hanger) && !oK(RestrictedHolder) ? true : nil	// ! small surfaces need to set to nil
	 dmgdThrown = nil
	 dmgsThrown = true
	 dmgdThrownAt = nil
	 dmgsThrownAt = true
	 alwaysAllowThrow = nil
	 alwaysAllowThrowAt = nil
	//  shortRangeThrow = pD(&shortRangeThrowMsg,PDD)
	//  shortRangeThrowMsg = '<<TN>> doesn\'t have much of a range for being thrown. '
	 	//* don't override this with fC, bc iobj usu handles action and conflicting msgs will appear
	 thrown() { 
		processThrow(gIobj, &throwTargetHitWith); 
	 	if(dumpCtsOnThrow) dumpCts(true,self); } 	
	 dumpCtsOnThrow = (oK(Openable) && isOpen || !oK(Openable))
	 dumpCts(rpt,thrownObj) { local objToReport = nil; 
	 	foreach(local obj in cts) {
	 		if(!obj.isPortable || obj.oK(SmearedHoney) || obj==dart && dart.isStuck) continue;
	 		objToReport = true;
			if(obj.dumpCtsOnThrow) obj.dumpCts(nil,thrownObj);	//* don't show msg for recursively spilling containers
			if(obj.oK(Liquid)) obj.zap; //make stone floors wet?
			else obj.mI(thrownObj.location); }
		if(rpt && objToReport) say(dumpCtsMsg); }
	 dumpCtsMsg { if(oK(Surface)) return ',,,Everything that was resting on <<tN>> is dumped off. ';
	 	else return 'All the contents of <<tN>> are scattered out. '; }
	 	// return 'Everything that was resting on <<itObj>> is dumped off. ';
	 	// else return 'All of <<itPossAdj>> contents are scattered out. '; } //* generally better, but incongruous for overridden tTHW (garg)
	 nThrow = nBreakThrown
	 nBreakThrown = '<<one of>>\^<<tN>> might get damaged if you throw <<itObj>>, and there doesn\'t seem to be a good reason for that. <<or>>\^<<TN>> <<verbToBe>> probably better off unthrown. <<shuffled>>'
	 nThrowAt = nBreakThrownAt
	 nBreakThrownAt = '<<one of>>You don\'t want to risk damaging <<tN>> by throwing things at <<itObj>>. <<or>>You could damage <<tN>> if you go throwing things at <<itObj>>. <<shuffled>>'
	dontHurt = '<<one of>>That doesn\'t sound like a very conscientious treatment of <<tN>>. <<or>><<TN>> probably deserve<<isPlural?'':'s'>> better treatment. <<or>>It doesn\'t sound like you\'re trying to help your cause. <<or>>Can\'t you find anything more constructive to do with <<tN>> than that? <<shuffled>>'
	dyed = nil
	dyeObj(means?) { if(dyed) return; dyed = true; }	// override w msg for things that will turn purple (change descs,vocab)
     combustible = nil   /////   only set for portables?
	 unreachable = gone || (isIn(privyHole) && (!hookable || fishingPole.gone)) || 
	 	// (isIn(byGargsFeet) && !garg.gone) ||   //now allowing retrieving
	 	(isInList([cistern,cisternWater]) && (!floats || !gR('reservoirEmpty'))) || (isIn(animalYard) && panther.cS==prowlingState) || isIn(nearSnug) && snuggles.cS==snugBarking
     dontBurn = nil
     putInFire(fire?) { 
		if(dontBurn || combustible && zapCond) fC(dontBurnMsg);
		Each(aCts) if(obj.dontBurn || obj.combustible && obj.zapCond) fC(obj.dontBurnMsg);
		local non = aCts.subset({x:!x.combustible});
		local combust = aCts.subset({x:x.combustible});
		local cdest = !combustible ? self : (fire ?? goR); 
		Each(non) if(obj.isPortable) { obj.mI(cdest);  
				obj.wet = nil; obj.dryDmn.reset; }
			//* leave the noncombustibles in the fire, or in me if I'm not combustible
		Each(combust) if(obj.isPortable) { obj.zap; 
				obj.wet = nil; obj.dryDmn.reset; }
			//* shouldn't be anything to call stuck() at this point
     	if(combustible) {
			burnUp; }
		if(!makesSmoke) { wet = nil; 
			dryDmn.reset; } }
     burnUp(msg?) { 
		 reportAfter('<.p>'+ (msg ? msg : burnUpMsg)); 
		 new Fuse(self,&zap,0); } //* so inherited nI doesn't move the obj back into itself
     dontBurnMsg = 'You think that you might find better uses for <<tN>> than committing <<itObj>> to the flames. '
     burnUpMsg = '\^<<tN>> <<verbToBe>> consumed to nothing by the <<isIn(forgeCoals) ? 'heat of the coals':'flames'>>. '
     kBurn { if(isPortable && !combustible) fC('<<one of>>You\'ll hardly get <<thatObj>> to catch fire. <<or>>Do you have some molten lava to light <<thatObj>> with? <<shuffled>>');
     	else if(dontBurnObjs.iO(self) && zapCond) fC(dontBurnMsg);
     	fC(rand('Let us keep the pyromania in check. ',!isPortable ? 'Arson is not a venerable career to pursue. ':'Not everything needs to perish in flame. ',
		'We don\'t need to make experiments upon the combustibility of <<tN>>. ')); }
	hammerBlow() { fC(dontHit); }
		//"{You/he} pound{s} on <<tN>> with the smithy hammer... that probably didn't help its lifespan. "; }
    	//(zap some, broken obj replace)  (BrokenObj class, low vL)
    castedAt() { 
		if(propDefined(&nCastAt)) fC(nCastAt);
    	else if(isPortable) { 
    		if(oneHas(self)) fC('You can hardly cast at something you\'re holding. '); 
    		if(hookable) { 
				if(isInKind(Water)) { local n = isInKind(Water).tN; 
					mI(gac); 
					"Using some dexterity, you angle <<tN>> out of <<n>> with the fishing pole. "; }
    			else if(isInKind(BasicFire)) { local n = isInKind(BasicFire).tN;
    				mI(gac); 
					"You use the fishing pole to snag <<tN>> out of <<n>>. "; }
    			else if(isIn(privyHole)) { 
					mI(gac); 
					"Dangling down the fishhook, you are able to snag <<tN>> and pull <<itObj>> back up out of the privy. "; }
				else if(isIn(cistern)) { 
					mI(gac); 
					"Dangling down the fishhook, you are able to snag <<tN>> and pull <<itObj>> back up out of the cistern. "; }
				else if(isIn(byGargsFeet) && !garg.gone) { 
					mI(gac); 
					"With an amazingly favorable cast, you hook <<tN>> and reel <<itObj>> back to you without any interference on the monster\'s part. "; }
				// panther yard? or objs are always grabbable through fence?
				else hookPortable;
    			}
    		else if(!hookable) {
    			if(isInList([privyHole,cistern])) fC('You try, but cannot succeed in hooking <<tN>> with the dangling fishhook. ');
    			else fC('You probably wouldn\'t be able to get a hook on <<thatObj>> in any useful manner. '); }
    		else if(gac.canTouch(self)) fC('Unless you\'re practicing your casting aim, that seems quite pointless. '); 
    		else fC(uselessToHookMsg); }
    	else fC('<<oo>>On second thought, you decide there are better things to cast at with a fishing pole. 
			<<or>>You decide to wait for a more likely target to cast at. 
			<<or>>There are going to be more worthwhile things to cast at than <<thatObj>>. <<shf>>'); }
	hookPortable { mI(gac); 
		"You hook <<tN>> and take <<itObj>>. "; }
	uselessToHookMsg = 'Trying to hook <<tN>> with the fishing pole is not going to produce results. '
     shotAt(tranqed) { 
    	if(oneHas(self)) fC('It doesn\'t work too well to shoot at anything you\'re carrying. ');
    	if(propDefined(&nShootAt)) fC(nShootAt);
    	dart.processThrow(self,&dartTarget); }
     dartTarget(proj,path) { if(isInKind(BasicWater)) fC('It doesn\'t work too well to shoot at things that are submerged. '); 
    	if(dartSticks) { say(shotDesc); dart.mI(self); dart.isStuck = true; }
    	else getHitFallDestination(proj, path).receiveDrop(proj, 
    		(dartMisses ? new DropTypeMiss(self,path) : new DropTypeThrow(self, path))); } 
     dartSticks = propDefined(&dartSD)
     dartBounces = !dartSticks && !dartMisses
     dartMisses = nil
     //* dartSD = ""
     shotDesc = 'You aim the blowgun at <<tN>> and give it a big puff. <<if !gR('gunworks')>>The dart flies out the other end with surprising rapidity, considering the makeshift nature of your blowgun. <.r gunworks><<end>>The dart whizzes through the air and lodges in the surface of <<objName>>. '		;
     class DropTypeMiss: DropTypeThrow
     	standardReport(obj, dest) { local nominalDest;
        	nominalDest = dest.getNominalDropDestination();
			mainReport(&dartMissMsg,target_, nominalDest); }	;	modify playerActionMessages
	 dartMissMsg(target,dest) {  //more detail if nested in conts?
		 	return 'Your shot misses <<target.tN>>, and lands nearby. '; }	; modify Thing
	floats = nil
	cleaned = nil
	dosed = nil
	wet = nil
	underwater = !floats && isInKind(Water) && !oneHas(self) && !isInWhich({x:x.floats})
	underwaterDesc { if(!isInKind(Water).useUnderwaterDesc) desc;
		else "Examining <<tN>> would be much more productive if <<tN>> were not underwater. <<if !gR('wetjoke')>>One thing that you note about <<itObj>> is that <<itIsContraction>> very wet. <.tr wetjoke40>"; }
	wetDesc = "\^<<tN>> <<verbToBe>> <<if !underwater && !location.oK(BasicWater)>>still damp from the wetting <<itNom>> received. <<else>>quite wet as a consequence of being in water. "
	wetFeelDesc = "\^<<tN>> <<verbToBe>> <<if !underwater && !location.oK(BasicWater)>>still damp from the wetting <<itNom>> received. <<else>>quite wet as a consequence of being in water. "
	uwD = true	//* useWetDesc
	makeDry() { wet = nil; } 						// vv  override if gets damaged or changes state
	makeWet(startDrying?) { if(dontWet) fC(dontWetMsg); 
		wet = true; 
		if(propDefined(&isLit)) { if(propDefined(&makeLit)) makeLit(nil); else isLit = nil; } //exting. msg?
		if(startDrying) dryDmn.start; } 	//need ThState to replace voc('wet'); 
	dontWet = overrides(self,Thing,&dontWetMsg) 
	dontWetMsg = '<<TN>> would be better off without getting wet. '
	dryDmn = perInstance(new DryingDmn(self)) 
	driedAtCt = 10		dryingMsgCt = 6
	announceDry = nil //only held objs auto-announce
	neverAnnounceDry = nil //option for held objs
	dryingMsg = ''
	stdDryingMsg = '\^<<tN>> <<if oneHas(self)>>that you have <<end>><<if isPlural>>are<<else>>is<<end>> starting to dry out. '
	driedMsg = ''
	stdDriedMsg = '\^<<tN>> <<if isPlural>>have<<else>>has<<end>> dried out. ' // or 'off'
    dippedIn(liq) { if(liq==sedative) fC('There\'s probably no good reason to put the sedative on <<thatObj>>. '); 
    	else if(liq==honey) applyHoney;
    	else if(liq.oK(BasicWater)) { makeWet(true); say(kDip); } 
    	else "We aren\'t sure what you\'re trying to accomplish here. "; }
	pouredIn(liq,source) { fC(nLiqsIn); } //!!move cts to loc first (leave objs in bowl)
    pouredOn(liq,fromBody?) { 
		if((!isPortable || self==oogChair) && isIn(oogCottageLoc)) 
    		fC(oogCottageLoc.nPourHere);
		if(liq!=sedative) {
			if(propDefined(&nPourOnto)) fC(nPourOnto);
			if(dontWet) fC(dontWetMsg); 
			makeWet(true); }
    	if(fromBody) say('You splash some water from <<fromBody.fillName>> onto <<tN>><<if uwD>>, which will consequently be wet for awhile<<end>>. ');
		else if(liq==sedative) { say(kPourSedOnto); 
			dosed = true;
			return; }
    	else say(kPourOnto); 
		Each(liq.cts) obj.mI(getDropDestination(obj,nil));
    	liq.zap; }
    kPourOnto = 'You pour the <<gDobj.liquidName>> on <<tN>><<if uwD>>, which will consequently be wet <<one of>>for awhile<<or>>until <<itIsContraction>> dry<<or>>until <<itNom>> dr<<isPlural ? 'y':'ies'>><<shuffled>><<end>>. '   
	kPourSedOnto = 'You let a tiny bit of sedative drip onto <<tN>>, but it quickly evaporates. '	

	basicExamineFeel { feelDesc;
		if(wet && uwD) { "<.p>"; wetFeelDesc; } }
	basicExamine() { local info = getVisualSenseInfo();
        local t = info.trans;
        if(underwater) { underwaterDesc; }			//
        else if(getOutermostRoom() != getPOVDefault(gActor).getOutermostRoom()
			&& (!isInKind(MultiLoc) || !(isInKind(MultiLoc).locationList.iO(goR)))		//
            && propDefined(&remoteDesc))
        	{ remoteDesc(getPOVDefault(gActor)); }
        else if (t == obscured && propDefined(&obscuredDesc))
        	{ obscuredDesc(info.obstructor); }
        else if (t == distant && propDefined(&distantDesc))
        	{ distantDesc;  }
        else if (canDetailsBeSensed(sight, info, getPOVDefault(gActor)) )// ||  described ) //
				//(with ||described) this would be unrealistic for any dynamic descs that could have changed since you last xed it
        	{ if(useInitDesc()) { initDesc; }
          	else { desc; }
            described = true;
            examineStatus();
            if(wet && uwD) { "<.p>"; wetDesc; }   }										//
        else if (t == obscured) { defaultObscuredDesc(info.obstructor); }
        else if (t == distant) { "Examining <<tN>> would be more informative if you were nearer to <<itObj>>. "; } } //						//
	ILMsgs(verb,verbed,verbs?) { local lst = ILMessages.gNV; local str = lst[1];
		switch(lst[2]) { case vb: str += verb; break; case vbd: str += verbed; break;
			case vbs: if(verbs) str += verbs; else str += verb + 's'; break;
			default: break; }
		str += lst[3]; return str; }
	ILMsgsNV() { return '<<one of>>Typically, you want to perform an action that makes reasonable sense. <<or>>
		We don\'t quite understand your intent here. <<or>>
		This makes us <<one of>>a little<<or>>just a shade<<or>>a trifle<<shuffled>> less certain of your competence. <<or>>
		This is a <<one of>>curious<<or>>peculiar<<or>>singular<<shuffled>> request you make... <<or>>
		There is a high likelihood that what you\'re trying to do is not of importance. <<shuffled>>'; }
	ILAMsgs(verb, verbed, nonPerm?) { local ia; if(nonPerm) ia = ILAMessagesWNP; else ia = ILAMessages;
		local lst = ia.gNV; local str = lst[1];
		switch(lst[2]) { case vb: str += verb; break; case vbd: str += verbed; break;
			default: break; }
		str += lst[3]; str = str.findReplace('verb',verb); return str; }
	ILSMsgs(verb,verbing,prep='with') { local str = ILSMessages.gNV;
		str = str.findReplace('theobj', tN);
		if(isPlural) str = str.findReplace('itself','themselves');
		str = str.findReplace('prep',prep); str = str.findReplace('verbing',verbing);
		str = str.findReplace('verb',verb); return str; } 
	noEffMsgs(verb,verbing,prep?) { local ne = (prep && gIobj ? noEffMessagesTI : noEffMessages);
		local str = ne.gNV; if(prep) str = str.findReplace('prep',prep);
		str = str.findReplace('verbing',verbing);
		str = str.findReplace('verb',verb); return str; }
	dismissMsgs(verb,verbing,prep?) { local ne = (prep && gIobj ? dismissMessagesTI : dismissMessages);
		local str = ne.gNV; if(prep) str = str.findReplace('prep',prep);
		str = str.findReplace('verbing',verbing);
		str = str.findReplace('verb',verb); return str; }
	dismiss() { return dismissNVMessages.gNV; }
	nImpMsgs(obj) { local str = nImpMessages.gNV; str = str.findReplace('theobj','{the <<
		gIobj && gIobj.oK(L45) ? 'i' : 'd'>>obj/he}');
		return str; }
	// * these are only overridden if macro for custom listers is used *
	initListers() { initCL(); initDL(); initLL(); initInL(); }
	initCL() { }	initDL() { }	initLL() { }	initInL() { }	initOL() { }	initAL() { }
	selectLister(type) {switch(type) {
	  case 'cl' : if(oK(Surface)) return new surfaceContentsLister;
		else if(oK(Underside)) return new undersideContentsLister;
		else if(oK(RearContainer) || oK(RearSurface)) return new rearContentsLister;
		else return new thingContentsLister; 
	  case 'dcl' : if(oK(Openable)) return new openableDescContentsLister;
		else if(oK(Surface)) return new surfaceDescContentsLister;
		else if(oK(Underside)) return new undersideDescContentsLister;
		else if(oK(RearContainer) || oK(RearSurface)) return new rearDescContentsLister;
		else return new thingDescContentsLister; 
	  case 'lil' : if(oK(Surface)) return new surfaceLookInLister;
		else if(oK(Underside)) return new undersideLookUnderLister;
		else if(oK(RearContainer) || oK(RearSurface)) return new rearLookBehindLister;
		else return new thingLookInLister; 
	  case 'icl' : if(oK(Surface)) return new surfaceInlineContentsLister;
		else if(oK(Underside)) return new undersideInlineContentsLister;
		else if(oK(RearContainer) || oK(RearSurface)) return new rearInlineContentsLister;
		else return new inlineListingContentsLister;
	  case 'acl' : if(oK(Underside)) return new undersideAbandonContentsLister;
	  	else if(oK(RearContainer)) return new rearAbandonContentsLister;
	  case 'ool' : return new openableOpeningLister;
	  default: return nil; 
		} }

	realm = 'Dwindeldorn'	realmCity = 'Darchingcrast'		lake = 'Great Skalfyrth Water'
	realmPeople = 'Dwindlings'	realmPerson = 'Dwindling'	frLake = 'the long frozen lake'
	firth = 'the Firth of Cairnash' 	oldRealmCity = 'Dorn Wharkmor'	
	House = 'Dubious Renown'
	PC = 'Valkyrian'	PCNickname = 'Valk'	

;//===========================================================================================================

	/////////////////     T O P I C S      ///////////////////////
	// KTopic:  isKnown = true ;  default is set to nil
tBusiness: KTopic 'their his business' 'what\'s going on' QUAL;
tFortunes: KTopic 'his (better) (good) (bad) (miserable) fortune/fortunes' 'how things are going' QUAL;
tName: KTopic '(what) (is) (their) (his) (her) (its) name name/names' 'names' QUAL; //find gender of actor?
tAge: KTopic '(how) old (he) (she) (what) (is) (their) (his) (her) (its) age/ages' ;
tChess: KTopic 'chess (game)/chess' 'chess' QUAL;
tOverworld: KTopic 'overworld' 'the Overworld' QUAL;
tRegions: KTopic '(region) regions (of) eternal (night)' 'the Regions of Eternal Night' QUAL ;
tVatterdelm: KTopic 'realm kingdom (of) vattyrdelm' ;
tAzhgaloth: KTopic 'realm kingdom (of) azhgaloth' ;
tCrindarwald: KTopic 'realm kingdom (of) crindarwald' ;
tBlykanfarth: KTopic 'realm kingdom (of) blykanfarth' ;
tEmdenfall: KTopic 'realm kingdom (of) emdenfall' ;
tEzgobatar: KTopic 'realm kingdom (of) ezgobatar' ;
tKunjahar: KTopic 'realm kingdom (of) kunjahar' ;
tUhongKmu: KTopic 'realm kingdom (of) uhong kmu' ;
tDirections: KTopic 'direction/directions' 'directions' QUAL;
//	K N I G H T S '   T O P I C S
tMyrgweth: Topic 'lord myrgweth' 'Lord Myrgweth' QUAL;
tQuest: Topic 'quest/mission' 'quest';
tSandWitch: KTopic '(the) sand witch (of) (skelgarn) witch/eldesga' 'the Sand Witch' QUAL;  //why K
tSpittoons: Topic '(eight) shield shields spittoon/spittoons/blob/blobs/heraldry' 'spittoons' ;
tDaughters: Topic 
	'daughter daughters niece nieces (of) (thymeleigh) (manor) (lord) (myrgweth) (myrgweth\'s) lady vannella erileitha sylverleigh riveldra larawyn firiuna lylova wayfair elegant lovely daughter/daughters/niece/nieces/damsel/damsels/maiden/maidens/lady/ladies' 'Myrgweth\'s daughters' QUAL;
tGlancelot: KTopic 'sir glancelot' 'Sir Glancelot' QUAL ;
tLoyne: KTopic 'sir loyneberger' 'Sir Loyneberger' QUAL ;
tEnders: KTopic 'sir enders' 'Sir Enders' QUAL ;
tOtherKnights: KTopic 'sir gruvith hal (of) uggleigh chancelot chantselot rantselot tiffiket dipozzet grantselot trancelot ennity pluss pantselot vyvel dephyttis' ;
tGlanceMaidens: KTopic 'maiden tywonne floris (of) brockley lady tacabelle' ;
tBadlands: KTopic 'skelgarn bad (land)/(lands)/badland/badlands' ;
// G R A N N Y  T O P I C S
tZenny: KTopic '(high) lord zenny/zendark/zendarc' 'Lord Zendarc' QUAL;
tFrozenNorth: Topic 'frozen north' 'the frozen north' QUAL;
tFadedCabbage: Topic 'faded cabbage' 'faded cabbage' QUAL
	askAnswer = "<<gDobj.TN>> probably wouldn\'t know what you\'re talking about. ";
tLegends: KTopic '(old) ancient stories/legend/legends/tale/tales/<<Thing.realm>>' 'ancient stories' ;
tDrackenFells: KTopic 'mysterious haunted fastness dracken fells (the) (of) -' 'the Dracken Fells' QUAL drawable = true ;
tCrown: KTopic 'sapphire hidden lost crown (of) dwindeldorn crown' ;
tOrganSong: Topic '(what) (to) play playing (on) (the) organ note notes song music' isKnown = organ.seen ;
tSongOfDF: Topic 'song (of) (the) (dracken) (fells) song' ;
// M O N K  T O P I C S
tDressCode: KTopic 'dress proper code/attire' 'dress code' ;
tWorldlyTripe: KTopic 'superfluous worldly tripe' 'worldly tripe' QUAL;
tUzumbung: Topic 'uzumbung island/uzumbung' 'Island of Uzumbung' QUAL;
tTuttarumbish: Topic 'wild savage (men)/(people)/tribe/tuttarumbish/tutta/pulapyuk' 'the Tuttarumbish' QUAL;
tExpedition: Topic 'random chance hazard trial error search/journey/expedition/searches/journeys/expeditions' 'expeditions' PLU;
// O T H E R
tWayfarer: Topic 'wayfarer wayfarer\'s woe' 'the Wayfarer\'s Woe' QUAL;
tDetnezerk: Topic 'his sublime magnificence (uzumbung) king lyin zerk/detnezerk/king/(uzumbung)/(island)' 'Detnezerk' QUAL;
tThug: Topic 'olarigor (the) thug lord thug-lord (of) (blad) (voktorn) her captor/olarigor/thug' ;
tFraud: KTopic '(doctor) (doctor\'s) fake scheme/scam/fraud/(medicine)' 'fraud' ; 
tCheating: KTopic 'cheat/cheating/cheater' 'cheating' QUAL;
tInterpret: KTopic 'interpret/interpreter/interpreting/interpretation/translate/translating/translator/translation/language/lingo/gibberish' 'interpreting' MASS;
tGift: Topic 'big gift/gifts' 'gifts' QUAL; 
tHelp: KTopic 'help/assistance' QUAL;
tIdea: KTopic '(a) (an) (some) nudge/idea/ideas' ;
tWork: KTopic 'farm farming work/labor/employment' ;
tMonks: KTopic 'mining minynge monk monks monkes monastery (at) (of) mowm cnizhbeledh monk/monks' 'the Mining Monks of Mowm' QUAL ;
tFestival: KTopic 'great festival' ;
