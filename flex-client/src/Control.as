import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.net.URLRequest;
import flash.utils.Timer;

import model.InterPerspective;
import model.Room;

import mx.collections.ArrayCollection;
import mx.collections.SortField;
import mx.collections.XMLListCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.ItemClickEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.utils.ArrayUtil;

import spark.components.ButtonBar;
import spark.events.IndexChangeEvent;

import view.AttitudeForm;
import view.AttitudeSliderSkin;
import view.MessageRenderer;
import view.RoomEvent;
import view.RoomResultRenderer;


[Bindable]
public var chatModel:InterPerspective;
public var attitudeForm:AttitudeForm;
public var timer:Timer;

function onCreationComplete() : void {
    var host:String = FlexGlobals.topLevelApplication.parameters.host;
    var port:int = FlexGlobals.topLevelApplication.parameters.port;
    var user_id:int = FlexGlobals.topLevelApplication.parameters.user_id;

    rootPath = FlexGlobals.topLevelApplication.parameters.root_path;
    chatModel = new InterPerspective(FlexGlobals.topLevelApplication as Main);
    if(user_id < 0){
        currentState = "readOnly";
    }
    else{
        chatModel.connect(host, port);
    }
    getRoomService.send();
    getResultsService.send();
    
    addEventListener(RoomEvent.DISPLAY_LOG, navigateToRoomLog);
}

function navigateToRoomLog(event:RoomEvent) : void {
    var url:String = rootPath + "/rooms/" + event.room.id;
    var request:URLRequest = new URLRequest(url);
    navigateToURL(request, "log");
}

function showAttitudeForm() : void {
    attitudeForm = PopUpManager.createPopUp(this, AttitudeForm, true) as AttitudeForm;
    attitudeForm.submitButton.addEventListener(MouseEvent.CLICK, postAttitude);
    PopUpManager.centerPopUp(attitudeForm);
    attitudeForm.attitudePositionInput.value = int(getRoomService.lastResult.room.attitude.position);
    attitudeForm.attitudeTitleInput.text = getRoomService.lastResult.room.attitude;
}

function setSort(event:IndexChangeEvent) : void {
    var f:SortField = ButtonBar(event.target).selectedItem as SortField;
    chatModel.setSortField(f);
}

function labelForSortField(o:Object) : String {
    var sortField:SortField = o as SortField;
    return chatModel.sortLabels[sortField.name];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// HTML response handlers
///////////////////////////////////////////////////////////////////////////////////////////////////

function onRoomLoaded(event:ResultEvent) : void {
    if(event.result.room.id){
        currentState = 'startup';
        roomPath = rootPath + "/rooms/" + event.result.room.id;
        participationID = event.result.room.participation.id;
        callLater(updateAttitudeInput);
        getRoomMessagesService.send();
        getRoomUsersService.send();
        getRoomFinishTimeService.send();
    }
    else{
        currentState = 'lobby';
    }
}

function onDemoRoomLoaded(event:ResultEvent) : void {
    currentState = 'readOnly';
    roomPath = rootPath + "/rooms/" + event.result.room.id;
    participationID = event.result.room.participation.id;
    getRoomMessagesService.send();
    getRoomUsersService.send();
//    getRoomFinishTimeService.send();
}

function updateAttitudeInput() : void {
//    attitudePositionInput.value = int(getRoomService.lastResult.room.attitude.position);
//    attitudeTitleInput.text = getRoomService.lastResult.room.attitude;    
}


function onMessagesLoaded(event:ResultEvent) : void {
    chatModel.messages = new XMLListCollection(event.result.message);
    chatModel.messages.refresh();
}


function onRoomUsersLoaded(event:ResultEvent) : void {
    chatModel.updateRoomUsers(event.result.user);
}

function onResultsLoaded(event:ResultEvent) : void {
    chatModel.updateResult(event.result.room);
}

function onRoomFinishTimeLoaded(event:ResultEvent) : void {
    roomFinishTime = new Date(event.result.room.finish_at);
    initTimer();
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Post
///////////////////////////////////////////////////////////////////////////////////////////////////

function postParticipate() : void {
    postParticipateService.send(chatModel.postParticipateParams());
}

function postMessage() : void {
    if(messageTextArea.text && messageTextArea.text.length > 0){
        postMessageService.send(chatModel.postMessageParams(messageTextArea.text));
        callLater(clearTextInput);
    }
    messageTextArea.setFocus();
}

function clearTextInput() : void {
    messageTextArea.text = null;
}


function postAttitude(e:MouseEvent) : void {
    var title:String = attitudeForm.attitudeTitleInput.text;
    var position:int = attitudeForm.attitudePositionInput.value;
    if(title){
      postAttitudeService.send(chatModel.postAttitudeParams(title, position));
      switch(currentState){
          case "startup":
              currentState = "room";
              break;
          case "timeup":
              currentState = "lobby";
      }
    }
    PopUpManager.removePopUp(attitudeForm);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Get
///////////////////////////////////////////////////////////////////////////////////////////////////

public function reloadUsers() : void {
    getRoomUsersService.send();
    
}

public function reloadFinishTime() : void {
    getRoomFinishTimeService.send();
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Timer
///////////////////////////////////////////////////////////////////////////////////////////////////

private function initTimer() : void {
    if(!timer){
        timer = new Timer(1000);
        timer.addEventListener(TimerEvent.TIMER, onTick);
    }
    if(!timer.running){
        timer.start();
    }
}

public function onTick(event:TimerEvent) : void {
    var now:Date = new Date();
    var sec:int = (roomFinishTime.valueOf() - now.valueOf()) / 1000;
    if(sec > 0){
        countdown.text = "残り時間あと" + int(sec / 60) + "分"+ sec % 60 + "秒";        
    }
    else{
        currentState = 'timeup';
        timer.stop();
        getResultsService.send();
    }
}

