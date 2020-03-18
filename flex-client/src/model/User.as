package model
{
    import mx.utils.StringUtil;

    [Bindable]
    public class User
    {
        private var _id:int;
        private var _name:String;
        private var _room:Room;
        private var _lines:int;
        private var _position:int; // 1..100
        private var _afterPosition:int; // 1..100
        private var _title:String;
        private var _afterTitle:String;
        private var _histogramPosition:int;
        
        public function User(id:int, name:String, room:Room, lines:int)
        {
            _id = id;
            _name = name;
            _room = room;
            _lines = lines;
            _position = 50; // start from middle position
            _afterPosition = -1; // if afterPosition < 0 then the position is not yet changed
            _histogramPosition = 1;
        }
        
        public function setAttitude(position:int, s:String) : void {
            _position = position;
            _title = s.replace(/\s/g, " ");
        }
        
        public function setAfterAttitude(position:int, s:String) : void {
            _afterPosition = position;
            _afterTitle = s.replace(/\s/g, " ");
        }
        
        public function get id():int { return _id; }
        public function get name():String { return _name; }
        public function get room():Room { return _room; }
        public function get lines():int{ return _lines; }
        
        public function get lineScore() : Number {
            return (lines - _room.ip.averageLines) / _room.ip.sdLines;
        }
        
        public function get position():int { return _afterPosition > 0 ? _afterPosition : _position; }
        public function get title():String { return _afterPosition > 0 ? _afterTitle : _title; }
        
        public function get beforePosition():int { return _position; }        
        public function get afterPosition():int { return _afterPosition; }
        
        public function get beforeTitle():String { return _title; }
        public function get afterTitle():String { return _afterTitle; }
        
        public function get hasChangedPosition():Boolean{
            return _afterPosition > 0 && Math.abs(_afterPosition - _position) > 5;
        }
        
        public function get change():int{
            return _afterPosition > 0 ? _afterPosition - _position : 0;
        }
        
        public function get changeScore():int{
            return hasChangedPosition ? (change > 0 ? change + 100 : -change) : 0;
        }
        
        public function set histogramPosition(i:int):void{ _histogramPosition = i; }
        public function get histogramPosition():int{ return _histogramPosition; }
    }
}