
ArrayList <PVector> Posistions = new ArrayList();
ArrayList <PVector> DistanceMoved = new ArrayList();
FloatList rotation = new FloatList();

float angle;

int numSat =50;
float r = 200;

PImage earth;
PShape globe;

JSONObject json;
JSONArray temp;
JSONObject SST;

boolean firstTime = true;

float rotateSpeed = 0;

void setup() {
  if (firstTime) {
    noStroke();
    globe = createShape(SPHERE, r);
    globe.setTexture(earth);
    firstTime = false;
  }
  for (int i = 0; i < numSat; i++) {
    String url = "https://www.n2yo.com/rest/v1/satellite/positions/"+i+"/55.769/12.502/0/4/&apiKey=GZ2KTQ-UB23BX-6VFN5P-4KFY";
    json = loadJSONObject(url);
    temp = json.getJSONArray("positions");
    SST = temp.getJSONObject(0);
    float lat = SST.getFloat("satlatitude");
    float lon = SST.getFloat("satlongitude");
    float alt = SST.getFloat("sataltitude");
    if (alt == 0) {
      continue;
    }
    PVector pos = new PVector(lat, lon, alt);
    Posistions.add(pos);
    SST = temp.getJSONObject(3);
    lat = SST.getFloat("satlatitude");
    lon = SST.getFloat("satlongitude");
    alt = SST.getFloat("sataltitude");
    pos = new PVector(lat, lon, alt);
    DistanceMoved.add(pos);
    rotation.append(0.00);
  }
  println(Posistions);
  println(DistanceMoved);
}

void settings() {
  size(800, 800, P3D);
  earth = loadImage("earth.jpg");
}

int counter = 0;
void draw() {
  background(51);
  translate(width*0.5, height*0.5);
  rotateY(angle);
  angle += rotateSpeed;

  lights();
  fill(200);
  noStroke();
  shape(globe);


  for (int i = 0; i < Posistions.size(); i++) {
    PVector loc = new PVector();
    PVector m = new PVector();
    loc = Posistions.get(i);
    m = DistanceMoved.get(i);
    float rot = rotation.get(i);

    float SclProduct = m.x*loc.x+m.y*loc.y;
    float mMag = m.mag();
    float locMag = loc.mag();
    float cosV = SclProduct/( abs(mMag) * abs(locMag));
    float v = acos(radians(cosV));


    float lat = loc.x;
    float lon = loc.y;
    float alt = loc.z;
    v *= alt/20000;

    alt = map(alt, 0, 4000, 200, 500);
    r = alt;

    float theta = radians(lat);

    float phi = radians(lon) + PI;

    float x = r * cos(theta) * cos(phi);
    float y = -r * sin(theta);
    float z = -r * cos(theta) * sin(phi);

    PVector pos = new PVector(x, y, z);


    PVector xaxis = new PVector(1, 0, 0);
    float angleb = PVector.angleBetween(xaxis, pos);
    PVector raxis = xaxis.cross(pos);

    rot += v/60;
    radians(rot);
    rotation.set(i, rot);

    pushMatrix();
    translate(0, 0, 0);
    rotate(rot);
    pushMatrix();
    translate(x, y, z);
    rotate(angleb, raxis.x, raxis.y, raxis.z);
    fill(255);
    box(5);
    popMatrix();
    popMatrix();
  }
}
void keyPressed() {
  if (key == 'a') {
    rotateSpeed -= 0.01;
  } else if ( key == 'd') {
    rotateSpeed += 0.01;
  }
}
