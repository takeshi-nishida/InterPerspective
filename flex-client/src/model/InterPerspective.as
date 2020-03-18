package model
{
    import flash.events.DataEvent;
    
    import mx.collections.ArrayCollection;
    import mx.collections.IViewCursor;
    import mx.collections.Sort;
    import mx.collections.SortField;
    import mx.collections.XMLListCollection;
    import mx.controls.Alert;
    
    import net.ChatProtocol;
    import net.UTFLineConnection;
    
    import util.ArrayCollectionMap;

    [Bindable]
    public class InterPerspective
    {		
        public const sortLabels:Object = { id:"新着順", variance:"意見が分散している順", change:"意見の変化度順", lines:"発言の多い順" };
        public const sortFields:ArrayCollection = new ArrayCollection([
            new SortField("id", false, true), new SortField("variance", false, true), new SortField("change", false, true), new SortField("lines", false, true)]);
//        public const userSortFields = [new SortField("changeScore", false, false)];
        public const userSortFields = [new SortField("lines", false, true)];

        private var protocol:ChatProtocol;
        private var connection:UTFLineConnection;

        private var application:Main;
        private var _postMessageParams:Object;
        private var _postAttitudeParams:Object;
        private var _postParticipateParams:Object;
        
        // data structures
        public var messages:XMLListCollection;
        public var currentRoom:Room;
        public var rooms:ArrayCollectionMap;
        public var users:ArrayCollection;
        
        // data statistics
        public var averagePosition:Number;
        public var averageLines:Number;
        public var sdLines:Number;
        public var leftSide:int;
        public var rightSide:int;
        public var changedToLeft:int;
        public var changedToRight:int;
        
        public function get unchanged() : int { return users.length - changedToLeft - changedToRight; }
        
        public function InterPerspective(application:Main)
        {
            this.application = application;
            rooms = new ArrayCollectionMap();
            users = new ArrayCollection();
            var sort:Sort = new Sort();
            sort.fields = userSortFields;
            users.sort = sort;

            initPostParams();
            initConnection();
        }
        
        public function connect(host:String, port:int) : void {
            connection.writeOnConnect = '#' + application.parameters.user_id;
            connection.connect(host, port);
        }
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // Set collection data
        ///////////////////////////////////////////////////////////////////////////////////////////////////

        public function updateRoomUsers(xmlList:XMLList) : void {
            currentRoom = new Room(xmlList.@id, this);
            currentRoom.updateUsers(xmlList);
        }
        
        public function updateResult(xmlList:XMLList) : void {
            rooms.removeAll();
            users.removeAll();

            for each (var xml:XML in xmlList){
                var room:Room = new Room(xml.@id, this);
                room.updateUsers(xml.user);
                rooms.addItem(room);
                users.addAll(room.users);                
            }
            users.refresh();

            updateStatistics();
            users.refresh();
            rooms.refresh();
        }
        
        private function updateStatistics() : void {
            leftSide = rightSide = changedToLeft = changedToRight = 0;
            var sumPosition:int = 0, sumLines:int = 0, sumLines2:int = 0;
            var histogramCount:Array = new Array(10);

            var cursor:IViewCursor = users.createCursor();
            while(!cursor.afterLast){
                var user:User = cursor.current as User;                
                sumPosition += user.position;
                sumLines += user.lines;
                sumLines2 += Math.pow(user.lines, 2);
                
                if(user.position > 50) rightSide++;
                else leftSide++;
                
                if(user.hasChangedPosition){
                    if(user.change > 0) changedToRight++;
                    else changedToLeft++;
                }
                
                var i:int = (user.position - 1) / 10;
                histogramCount[i] = histogramCount[i] ? histogramCount[i] + 1 : 1;
                user.histogramPosition = histogramCount[i];
                cursor.moveNext();
            }

            averagePosition = sumPosition / users.length;
            averageLines = sumLines / users.length;
            sumLines2 /= users.length;
            sdLines = Math.sqrt(sumLines2 - Math.pow(averageLines, 2));
        }
        
        public function setSortField(f:SortField) : void {
            var sort:Sort = new Sort();
            sort.fields = [f];
            rooms.sort = sort;
            rooms.refresh();
        }

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // Get post params
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        
        public function postMessageParams(body:String) : Object {
            _postMessageParams['message[body]'] = body;
            _postMessageParams['message[participation_id]'] = application.participationID;
            return _postMessageParams;
        }
        
        public function postAttitudeParams(title:String, position:int) : Object {
            _postAttitudeParams['attitude[title]'] = title;
            _postAttitudeParams['attitude[position]'] = position;
            _postAttitudeParams['attitude[participation_id]'] = application.participationID;
            return _postAttitudeParams;
        }
        
        public function postParticipateParams() : Object {
            return _postParticipateParams;
        }

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // Handle receive from socket
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        
        public function processLine(header:String, message:String) : void {
            var xml:XML = new XML(message);
            switch(xml.localName()){
                case "message":
                    if(messages){
                        messages.addItem(xml);
                        messages.refresh();
                    }
                    break;
                case "user":
                    currentRoom.updateUser(xml);
                    break;
            }
        }
                
        public function update_room_users(args:String) : void {
            Alert.show("update_room_users should not happen");
            application.reloadUsers();
        }
        
        public function update_room_finish_time(args:String) : void {
            application.reloadFinishTime();
        }

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        // Private methods
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        private function initPostParams() : void {
            var _authenticityToken:String = application.parameters.authenticity_token;
            _postMessageParams = { authenticity_token: _authenticityToken };
            _postAttitudeParams = { authenticity_token: _authenticityToken };
            _postParticipateParams = { authenticity_token: _authenticityToken };            
        }
        
        private function initConnection() : void {
            protocol = new ChatProtocol(this);
            connection = new UTFLineConnection();
            connection.addEventListener(DataEvent.DATA, protocol.lineReceived);
        }
    }
}