import java.util.HashMap;

import com.firebase.client.AuthData;
import com.firebase.client.ChildEventListener;
import com.firebase.client.DataSnapshot;
import com.firebase.client.Firebase;
import com.firebase.client.Firebase.AuthResultHandler;
import com.firebase.client.FirebaseError;
import com.firebase.geofire.GeoFire;
import com.firebase.geofire.GeoLocation;
import com.firebase.geofire.GeoQuery;
import com.firebase.geofire.GeoQueryEventListener;
import com.firebase.geofire.LocationCallback;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Set;
import java.util.TreeSet;
import java.util.concurrent.atomic.AtomicInteger;

import javax.net.ssl.SSLHandshakeException;

import com.firebase.client.ChildEventListener;
import com.firebase.client.DataSnapshot;
import com.firebase.client.Firebase;
import com.firebase.client.FirebaseError;
import com.relayrides.pushy.apns.ApnsEnvironment;
import com.relayrides.pushy.apns.FailedConnectionListener;
import com.relayrides.pushy.apns.PushManager;
import com.relayrides.pushy.apns.PushManagerConfiguration;
import com.relayrides.pushy.apns.RejectedNotificationListener;
import com.relayrides.pushy.apns.RejectedNotificationReason;
import com.relayrides.pushy.apns.util.ApnsPayloadBuilder;
import com.relayrides.pushy.apns.util.MalformedTokenStringException;
import com.relayrides.pushy.apns.util.SSLContextUtil;
import com.relayrides.pushy.apns.util.SimpleApnsPushNotification;
import com.relayrides.pushy.apns.util.TokenUtil;


public class Geo
{
    static PushManager<SimpleApnsPushNotification> pushManager = null;
    
    static boolean production = true;

    public static void main(String[] args) {
        try
        {
            pushManager = new PushManager<SimpleApnsPushNotification>(
                            ApnsEnvironment.getSandboxEnvironment(),
                            SSLContextUtil.createDefaultSSLContext(production ? "***" : "***", "***"),
                            null, // Optional: custom event loop group
                            null, // Optional: custom ExecutorService for calling listeners
                            null, // Optional: custom BlockingQueue implementation
                            new PushManagerConfiguration(),
                            "***");

            pushManager.start();
        }
        catch ( UnrecoverableKeyException | KeyManagementException
                        | KeyStoreException | NoSuchAlgorithmException
                        | CertificateException | IOException e1 )
        {
            // TODO Auto-generated catch block
            e1.printStackTrace();
            System.exit(0);
        }
        
        final PriorityQueue<Task> tasks = new PriorityQueue<Task>(11, new TaskComparator());

        final Firebase f = new Firebase("***");

        final HashMap<String, Location> responders = new HashMap<String, Location>();

        f.authWithCustomToken("***", new AuthResultHandler() {

            @Override
            public void onAuthenticated( AuthData auth )
            {
                final GeoFire geoFire = new GeoFire( f.child( "locations" ) );
                
                f.child("responder").addChildEventListener(new ChildEventListener() {
                    public void onCancelled(FirebaseError arg0) {}
                    public void onChildMoved(DataSnapshot arg0, String arg1) {}
                    
                    @Override
                    public void onChildRemoved(DataSnapshot responderData) {
                        responders.remove( responderData.getKey() );
                        geoFire.removeLocation( responderData.getKey() );
                    }

                    @Override
                    public void onChildAdded(DataSnapshot responderData, String before) {
                        
                        HashMap<String, Object> responderInfo = (HashMap<String, Object>)responderData.getValue();

                        if (responderInfo.containsKey("latitude") && responderInfo.containsKey("longitude") && responderInfo.containsKey("time") && 
                                        responderInfo.containsKey("distance") && responderInfo.containsKey("token")) {
                            Location l = new Location((double) responderInfo.get("latitude"), (double) responderInfo.get("longitude"), 
                                (double) responderInfo.get("time"), (long) responderInfo.get("distance"), (String) responderInfo.get( "token" ));
                            responders.put(responderData.getKey(), l);
                            
                            geoFire.setLocation( responderData.getKey(), new GeoLocation((double)responderInfo.get( "latitude" ), (double)responderInfo.get( "longitude" )) );
                        }
                        
                    }

                    @Override
                    public void onChildChanged(DataSnapshot responderData, String before) {

                        HashMap<String, Object> responderInfo = (HashMap<String, Object>)responderData.getValue();

                        if (responderInfo.containsKey("latitude") && responderInfo.containsKey("longitude") && responderInfo.containsKey("time") && 
                                        responderInfo.containsKey("distance") && responderInfo.containsKey("token")) {
                            Location l = new Location((double) responderInfo.get("latitude"), (double) responderInfo.get("longitude"), 
                                (double) responderInfo.get("time"), (long) responderInfo.get("distance"), (String) responderInfo.get( "token" ));
                            responders.put(responderData.getKey(), l);
                            
                            geoFire.setLocation( responderData.getKey(), new GeoLocation((double)responderInfo.get( "latitude" ), (double)responderInfo.get( "longitude" )) );
                        }

                    }

                });

                f.child("cpr").addChildEventListener(new ChildEventListener() {

                    public void onCancelled(FirebaseError arg0) {}
                    public void onChildMoved(DataSnapshot arg0, String arg1) {}
                    public void onChildRemoved(DataSnapshot arg0) {}
                    public void onChildChanged(DataSnapshot requestData, String before) {}

                    @Override
                    public void onChildAdded(DataSnapshot requestData, String before) {
                        final String requestID = requestData.getKey();
                        HashMap<String, Object> request = (HashMap<String, Object>) requestData.getValue();

                        final double latitude = (double) request.get("latitude");
                        final double longitude = (double) request.get("longitude");
                        final double alertTime = (double) request.get("time");

                        final Location l = new Location(latitude, longitude, alertTime, 0, "");
                        
                        System.out.println("Got a request.");
                        
                        final PriorityQueue<Responder> nearestResponders = new PriorityQueue<Responder>(11, new Comparator<Responder>() {
                            @Override
                            public int compare( Responder o1, Responder o2 )
                            {
                                // TODO Auto-generated method stub
                                if (o1.getDistance() < o2.getDistance()) {
                                    return -1;
                                } else if (o1.getDistance() > o2.getDistance()) {
                                    return 1;
                                }
                                return 0;
                            }
                        });
                        
                        
                        
                        final Set<String> inRange = new TreeSet<String>();
                        
                        GeoQuery geoQuery = geoFire.queryAtLocation(new GeoLocation(latitude,longitude), 4.82804);
                        
                        tasks.add( new Task(false, requestID, requestID, System.currentTimeMillis(), geoQuery) );
                        
                        final AtomicInteger responderCount = new AtomicInteger();
                        
                        geoQuery.addGeoQueryEventListener(new GeoQueryEventListener() {
                            
                            
                            @Override
                            public void onKeyEntered(String key, GeoLocation location) {
                                System.out.println(String.format("Key %s entered the search area at [%f,%f]", key, location.latitude, location.longitude));
                                
                                inRange.add( key );
                                
                                
                                if (!key.equals(requestID) && responders.containsKey( key ) && responders.get(key).withinRange(l)) {
                                    // Inform the responder about the request
                                    System.out.println("Found " + key + " as responder.");
                                    
                                    nearestResponders.add( new Responder(key, responders.get( key ).distFrom( latitude, longitude )) );
                                    
                                    if (responderCount.incrementAndGet() <= 3) {
                                        Responder resp = nearestResponders.poll();
                                        
                                        Firebase responderAlert = f.child("responder").child(resp.getUser()).child("alert").child(requestID);
                                        Map<String, Double> alerterData = new HashMap<String, Double>();
                                        alerterData.put( "latitude", latitude );
                                        alerterData.put( "longitude", longitude );
                                        alerterData.put( "time", alertTime );
                                        responderAlert.setValue( alerterData );

                                        Firebase requestReceivers = f.child("cpr").child(requestID).child("responders").child(resp.getUser());
                                        Map<String, Double> receiverData = new HashMap<String, Double>();
                                        receiverData.put( "latitude", responders.get(resp.getUser()).getLat() );
                                        receiverData.put( "longitude", responders.get(resp.getUser()).getLong() );
                                        requestReceivers.setValue( receiverData );
                                        
                                        tasks.add( new Task(true, resp.getUser(), requestID, System.currentTimeMillis(), null) );
                                        
                                        byte[] token = null;
                                        try
                                        {
                                            token = TokenUtil.tokenStringToByteArray(responders.get( resp.getUser() ).getToken());
                                        }
                                        catch ( MalformedTokenStringException e1 )
                                        {
                                            // TODO Auto-generated catch block
                                            e1.printStackTrace();
                                        }
                                        
                                        final ApnsPayloadBuilder payloadBuilder = new ApnsPayloadBuilder();

                                        payloadBuilder.setAlertBody("Alert: CPR Needed!");
                                        payloadBuilder.setSoundFileName("ring-ring.aiff");

                                        pushManager.registerRejectedNotificationListener( new RejectedNotificationListener<SimpleApnsPushNotification>() {

                                            @Override
                                            public void handleRejectedNotification(
                                                PushManager<? extends SimpleApnsPushNotification> arg0,
                                                SimpleApnsPushNotification arg1,
                                                RejectedNotificationReason arg2 )
                                            {
                                                System.out.println("Rejected!");
                                            }
                                            
                                        });
                                        
                                        pushManager.registerFailedConnectionListener( new FailedConnectionListener <SimpleApnsPushNotification> () {

                                            @Override
                                            public void handleFailedConnection(
                                                PushManager<? extends SimpleApnsPushNotification> arg0,
                                                Throwable arg1 )
                                            {
                                                System.out.println("SSL error!" + arg1);
                                                if (arg1 instanceof SSLHandshakeException) {
                                                    // Permanent failure, shut down
                                                    // the PushManager.
                                                    try
                                                    {
                                                        System.out.println( "certificate error" );
                                                        pushManager.shutdown();
                                                    }
                                                    catch ( InterruptedException e )
                                                    {
                                                        // TODO Auto-generated catch block
                                                        e.printStackTrace();
                                                    }
                                                }
                                            }
                                            
                                        });
                                        
                                        final String payload = payloadBuilder.buildWithDefaultMaximumLength();

                                        try
                                        {
                                            pushManager.getQueue().put(new SimpleApnsPushNotification(token, payload));
                                        }
                                        catch ( InterruptedException e1 )
                                        {
                                            // TODO Auto-generated catch block
                                            e1.printStackTrace();
                                        }
                                        catch ( Exception e ) {
                                            System.out.println("Exception!");
                                        }
                                    }
                                }
                            }
                            
                            public void onKeyExited(String key) {}
                            public void onKeyMoved(String key, GeoLocation location) {}
                            public void onGeoQueryReady() {}
                            public void onGeoQueryError(FirebaseError error) {}
                        });


                    }
                });
                
                
            }

            @Override
            public void onAuthenticationError( FirebaseError error )
            {
                System.out.println("[ ERROR ] Could not authenticate with Firebase.");
            }
            
        });
        
        while (true) {
            try {
                Thread.sleep(60000);
                while(tasks.size() > 0 && Math.abs(System.currentTimeMillis() - tasks.peek().getTime()) < 60000) {
                    tasks.poll().perform();
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
                try
                {
                    pushManager.shutdown();
                }
                catch ( InterruptedException e1 )
                {
                    // TODO Auto-generated catch block
                    e1.printStackTrace();
                }
            }
        }
    }
}
