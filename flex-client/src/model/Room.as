package model
{
    import flashx.textLayout.formats.Float;
    
    import mx.collections.IViewCursor;
    
    import util.ArrayCollectionMap;

    [Bindable]
    public class Room
    {
        private var _id:int;
        private var _ip:InterPerspective;
        public var users:ArrayCollectionMap;
        public var variance:Number; // 立ち位置の分散
        public var change:Number; // 立ち位置の変化量の平均
        public var lines:int;
        
        public function Room(id:int, ip:InterPerspective)
        {
            _id = id;
            _ip = ip;
            users = new ArrayCollectionMap();
        }
        
        public function get id() : int { return _id; }
        public function get ip() : InterPerspective { return _ip; }
        
        public function updateUsers(xmlList:XMLList) : void {
            for each(var xml:XML in xmlList){
                updateUser(xml);
            }
        
            updateStatistics();
        }
        
        private function updateStatistics() : void {
            var cursor:IViewCursor = users.createCursor();
            var sum:Number = 0; // 平均計算用
            var sum2:Number = 0; // ２乗の平均計算用
            change = lines = 0;
            while(!cursor.afterLast){
                var user:User = cursor.current as User;
                sum += user.position;
                sum2 += Math.pow(user.position, 2);
                change += Math.abs(user.change);
                lines += user.lines;
                cursor.moveNext();
            }
            variance = sum2 / users.length - Math.pow(sum / users.length, 2);
            change /= users.length;            
        }
        
        public function updateUser(xml:XML) : void {
            var user:User = xmlToUserAttitude(xml);
            users.removeItem(user.id);
            users.addItem(user);
            users.itemUpdated(user);
        }
        
        private function xmlToUserAttitude(xml:XML) : User {
            var u:User = new User(int(xml.@id), xml['name'], this, int(xml.@lines));
            if(xml.before){
                u.setAttitude(int(xml.before.@position), String(xml.before));
            }
            if(xml.after){
                u.setAfterAttitude(int(xml.after.@position), String(xml.after));
            }
            return u;
        }
    }
}