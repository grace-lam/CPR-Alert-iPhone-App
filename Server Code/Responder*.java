    
public class Responder
{
    private String userID;
    private double distance;

    public Responder( String user, double dist )
    {
        userID = user;
        distance = dist;
    }
    
    public String getUser() {
        return userID;
    }
    
    public double getDistance() {
        return distance;
    }

}
