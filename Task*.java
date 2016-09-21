import java.util.Comparator;

import com.firebase.client.Firebase;
import com.firebase.geofire.GeoQuery;


public class Task
{
    private boolean responder;

    private String userID;

    private String requestID;

    private long originalTime;
    
    private GeoQuery geo;

    final long TIME_LAPSE = 900000; // 15 minutes

    final Firebase f = new Firebase( "***" );


    public Task(
        boolean isResponder,
        String user,
        String requester,
        long currTime,
        GeoQuery geo)
    {
        responder = isResponder;
        userID = user;
        requestID = requester;
        originalTime = currTime;
        this.geo = geo;
    }


    public long getTime()
    {
        return originalTime + TIME_LAPSE;
    }


    public void perform()
    {
        if ( responder )
        {
            f.child( "responder" )
                .child( userID )
                .child( "alert" )
                .child( requestID )
                .removeValue();
        }
        else
        {
            f.child( "cpr" ).child( userID ).removeValue();
            geo.removeAllListeners();
        }
    }
}


class TaskComparator implements Comparator<Task>
{
    @Override
    public int compare( Task o1, Task o2 )
    {
        // TODO Auto-generated method stub
        if (o1.getTime() < o2.getTime()) {
            return -1;
        } else if (o1.getTime() > o2.getTime()) {
            return 1;
        }
        return 0;
    }
}
