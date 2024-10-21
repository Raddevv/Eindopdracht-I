// achtergrond variabelen
boolean shoot;
boolean gameOver = false;
boolean restart = false;
int teller;
int score = 0;
int waveNum = 1;
ArrayList<Ster> sterren = new ArrayList<Ster>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Laser> lasers = new ArrayList<Laser>();
ArrayList<PowerUp> powerUps = new ArrayList<PowerUp>();

// player schip variabelen
color schipKleur;
color defaultSchipKleur = color(0, 0, 0);
color multiLaserSchipKleur = color(255,255,255);
float schipX;
float schipY;
float schipWidth = 40;
float schipHeight = 60;
float snelheid = 15;
boolean left = false, right = false, space = false;
boolean powerUpSnelheid = false;
boolean powerUpSnelereSchietfrequentie = false;
boolean powerUpMultiLaser = false;

// player int variabelen
int playerHealth = 5;
int powerUpSnelheidTimer = 0;
int powerUpSchietTimer = 0;
int powerUpMultiLaserTimer = 0;
int powerUpDuration = 500;

// game setup
void setup() {
  shoot = false;
  teller = 0;
  size(900, 950);
  background(0, 0, 0);

  schipX = width / 2;
  schipY = height - 100;

  schipKleur = defaultSchipKleur;

  maakSterren();
  startWave();
}


// wave management
void startWave() {
  enemies.clear();
  for (int i = 0; i < 5 + waveNum * 5; i++) {
    enemies.add(new Enemy(100 + (i % 10) * 80, 50 + (i / 10) * 60, 1, 0.25 + waveNum * 0.1, 1));
  }
}

// ster management
void maakSterren() {
  for (int i = 0; i < 2000; i++) {
    sterren.add(new Ster(random(width), random(height)));
  }
}

// laser class
class Laser {
  float x;
  float y;
  float snelheid = 60;
  float breedte = 5;
  float hoogte = 1200;

  Laser(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void beweging() {
    y -= snelheid;
  }

  void laserZichtbaar() {
    int R = (int)random(55, 255);
    int G = (int)random(55, 255);
    int B = (int)random(55, 255);
    fill(199, 250, 255);
    stroke(R, G, B);
    ellipse(x - breedte / 2, y - hoogte / 2, breedte, hoogte);
  }

  boolean isOffScreen() {
    return y < 0;
  }

  boolean raaktEnemy(Enemy e) {
    return x > e.x && x < e.x + e.enemyWidth && y > e.y && y < e.y + e.enemyHeight;
  }
}

// enemy class
class Enemy {
  float x, y;
  float enemyWidth = 50;
  float enemyHeight = 50;
  float snelheid;
  int health;
  boolean isDead = false;

  Enemy(float x, float y, float snelheid, float bewegingSnelheid, int health) {
    this.x = x;
    this.y = y;
    this.snelheid = bewegingSnelheid;
    this.health = health;
  }

  void move() {
    y += snelheid;
    if (y > height) {
      score -= 10;
      isDead = true;
    }
  }

  void show() {
    if (!isDead) {
      fill(255, 255, 255);
      noStroke();
      ellipse(x, y, enemyWidth, enemyHeight);
    }
  }

  void hit() {
    health--;
    if (health <= 0) {
      vernietigen();
    }
  }

  void vernietigen() {
    isDead = true;

    if (random(1) < 0.025) {
      powerUps.add(new PowerUp(x, y));
    }
  }
}

// power up class
class PowerUp {
  float x, y;
  float breedte = 20;
  float hoogte = 20;
  float snelheid = 3;
  int type;

  PowerUp(float x, float y) {
    this.x = x;
    this.y = y;
    this.type = (int)random(1, 5);
  }

  void move() {
    y += snelheid;
  }

  void show() {
    if (type == 1) {
      fill(241, 148, 138);
    } else if (type == 2) {
      fill(169, 204, 227);
    } else if (type == 3) {
      fill(163, 228, 215);
    } else if (type == 4) {
      fill(210, 180, 222);
    }
    noStroke();
    ellipse(x, y, breedte, hoogte);
  }

  boolean raaktSpeler() {
    return x > schipX - schipWidth / 2 && x < schipX + schipWidth / 2 && y > schipY - schipHeight / 2 && y < schipY + schipHeight / 2;
  }
}

// ster class
class Ster {
  float x, y;
  float grootte;

  Ster(float x, float y) {
    this.x = x;
    this.y = y;
    this.grootte = random(1, 4);
  }

  void show() {
    int R = (int)random(150, 255);
    int G = (int)random(150, 255);
    int B = (int)random(150, 255);
    fill(R, G, B);
    noStroke();
    ellipse(x, y, grootte, grootte);
  }
}

//achtergrond trekken
void trekAchtergrond() {
  background(0, 0, 0);
  for (Ster s : sterren) {
    s.show();
  }
}

// speler tekenen
void trekSchip() {
  int R = (int)random(165, 255);
  int G = (int)random(165, 255);
  int B = (int)random(165, 255);

  if (powerUpMultiLaser) {
    schipKleur = multiLaserSchipKleur; 
  } else {
    schipKleur = defaultSchipKleur;
  }

  fill(schipKleur);
  stroke(R, G, B);
  strokeWeight(2);
  triangle(schipX, schipY - schipHeight / 2,
    schipX - schipWidth / 1, schipY + schipHeight / 4,
    schipX + schipWidth / 1, schipY + schipHeight / 4);

  schipX = constrain(schipX, schipWidth / 24, width - schipWidth / 2);

  if (teller >= (powerUpSnelereSchietfrequentie ? 1 : 2) && space) {
    lasers.add(new Laser(schipX, schipY - schipHeight / 6));

    if (powerUpMultiLaser) {
      lasers.add(new Laser(schipX - 35, schipY - schipHeight / 60));
      lasers.add(new Laser(schipX + 35, schipY - schipHeight / 60));
    }

    teller = 0;
  } else {
    teller++;
  }
}

// speler beweging
void beweegSpaceship() {
  if (left) {
    schipX -= (powerUpSnelheid ? 2 * snelheid : snelheid);
  }
  if (right) {
    schipX += (powerUpSnelheid ? 2 * snelheid : snelheid);
  }
}

// enemy speler geraakt
void checkCollision() {
  for (Enemy e : enemies) {
    if (!e.isDead && schipX > e.x && schipX < e.x + e.enemyWidth && schipY > e.y && schipY < e.y + e.enemyHeight) {
      playerHealth--;
      if (playerHealth <= 0) {
        gameOver = true;
      }
      e.vernietigen();
    }
  }
}


// power up speler geraakt
void checkPowerUpCollision() {
  for (int i = powerUps.size() - 1; i >= 0; i--) {
    PowerUp p = powerUps.get(i);
    p.move();

    p.show();
    if (p.raaktSpeler()) {
      if (p.type == 1) {
        powerUpSnelheid = true;
        powerUpSnelheidTimer = powerUpDuration;
      } else if (p.type == 2) {
        powerUpSnelereSchietfrequentie = true;
        powerUpSchietTimer = powerUpDuration;
      } else if (p.type == 3) {
        playerHealth++;
      } else if (p.type == 4) {
        powerUpMultiLaser = true;
        powerUpMultiLaserTimer = powerUpDuration;
      }
      powerUps.remove(i);
    }

    // power up buiten scherm verwijderen
    if (p.y > height) {
      powerUps.remove(i);
    }
  }
}

// score zichtbaar
void toonScore() {
  fill(255, 255, 255);
  textSize(40);
  text("Score: " + score, 50, 50);
  text("Health: " + playerHealth, 50, 90);
}

// enemy beweging
void gameMechanics() {
  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy e = enemies.get(i);
    e.move();
    e.show();
    // enemy geraakt
    for (int j = lasers.size() - 1; j >= 0; j--) {
      Laser l = lasers.get(j);
      if (l.raaktEnemy(e)) {
        e.hit();
        score += 5;
        lasers.remove(j);
      }
    }
    // enemy dood detectie
    if (e.isDead) {
      enemies.remove(i);
    }
  }

  // laser zichtbaar tijdens schieten
  for (int i = lasers.size() - 1; i >= 0; i--) {
    Laser l = lasers.get(i);
    l.beweging();
    l.laserZichtbaar();
    // laser verwijderen buiten scherm
    if (l.isOffScreen()) {
      lasers.remove(i);
    }
  }
  // volgende wave aanmaken
  if (enemies.isEmpty()) {
    waveNum++;
    startWave();
  }
}

// power up timer
void updatePowerUpTimers() {
  if (powerUpSnelheidTimer > 0) {
    powerUpSnelheidTimer--;
  } else {
    powerUpSnelheid = false;
  }

  if (powerUpSchietTimer > 0) {
    powerUpSchietTimer--;
  } else {
    powerUpSnelereSchietfrequentie = false;
  }

  if (powerUpMultiLaserTimer > 0) {
    powerUpMultiLaserTimer--;
  } else {
    powerUpMultiLaser = false;
    schipKleur = defaultSchipKleur;
  }
}



// teken void
void draw() {
  if (!gameOver) {
    trekAchtergrond();
    beweegSpaceship();
    trekSchip();
    checkCollision();
    gameMechanics();
    checkPowerUpCollision();
    toonScore();
    updatePowerUpTimers();
  } else {
    // game over scherm
    background(0, 0, 0);
    fill(255, 255, 255);
    textSize(100);
    text("GAME OVER", width / 2 - 300, height / 2);
    textSize(50);
    text("Press 'R' to Restart", width / 2 - 230, height / 2 + 80);

    if (restart) {
      resetGame();
    }
  }
}

// reset voor restart
void resetGame() {
  gameOver = false;
  restart = false;
  playerHealth = 5;
  score = 0;
  waveNum = 1;
  enemies.clear();
  powerUps.clear();
  lasers.clear();
  startWave();
}

// bewegings functionaliteit
void keyPressed() {
  if (key == ' ') {
    space = true;
  }
  if (key == 'a') {
    left = true;
  }
  if (key == 'd') {
    right = true;
  }
  if (key == 'r') {
    restart = true;
  }
}

// bewegingstoetsen los
void keyReleased() {
  if (key == ' ') {
    space = false;
  }
  if (key == 'a') {
    left = false;
  }
  if (key == 'd') {
    right = false;
  }
}
