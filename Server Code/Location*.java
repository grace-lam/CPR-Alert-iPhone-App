public class Location
{
    double latitude;
    double longitude;
    double locTime;
    long maxDistance;
    String token;
    
    final double maxTimeDifference = 60 * 10; 

    public Location( double latitude, double longitude, double time, long dist, String token )
    {
        this.latitude = latitude;
        this.longitude = longitude;
        locTime = time;
        maxDistance = dist;
        this.token = token;
    }

    public double getLat() {
        return latitude;
    }

    public double getLong() {
        return longitude;
    }

    public double getTime() {
        return locTime;
    }
    
    public String getToken() {
        return token;
    }

    public boolean withinRange( Location other ) {
        return ( other.getTime() - locTime <= maxTimeDifference )
            && ( distFrom( other.getLat(), other.getLong() ) <= maxDistConvert( maxDistance ) );
    }

    public double maxDistConvert( long dist ) {
        if (dist == 0) {
            return 1;
        } else if (dist == 1) {
            return 2;
        } else {
            return 3;
        }
    }
    
    public double distFrom(double lat1, double lng1) {
        double earthRadius = 3958.75; // miles (or 6371.0 kilometers)
        
        double dLat = Math.toRadians(latitude-lat1);
        double dLng = Math.toRadians(longitude-lng1);
        double sindLat = Math.sin(dLat / 2);
        double sindLng = Math.sin(dLng / 2);
        double a = Math.pow(sindLat, 2) + Math.pow(sindLng, 2)
                * Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(latitude));
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        double dist = earthRadius * c;

        return dist;
    }
}