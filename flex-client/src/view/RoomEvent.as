package view
{
    import flash.events.Event;
    
    import model.Room;
    
    public class RoomEvent extends Event
    {
        public static const DISPLAY_LOG:String = "display_log";
        
        private var _room:Room;
        
        public function RoomEvent(type:String, room:Room)
        {
            super(type, true, true);
            _room = room;
        }
        
        public function get room() : Room {
            return _room;
        }
        
        public function clonse() : Event {
            return new RoomEvent(type, _room);
        }
    }
}