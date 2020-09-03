
import processing.sound.*;

SoundFile bullet_sound; // variable for bullet sound
SoundFile music; // variable for music

Ship ship; // object for ship

boolean upPressed = false;//CHANGE LEFT AND RIGHT TO UP AND DOWN( IN SHIP TOO)
boolean downPressed = false;
boolean rightPressed = false;
boolean leftPressed = false;

float shipSpeed = 2;
float bulletSpeed = 10;

int numAsteroids = 4; //the number of asteroids
int startingRadius = 50; //the size of an asteroid

PImage asteroidPic;
PImage rocket;

ArrayList<Bullet> bullets;
ArrayList<Asteroid> asteroids;

PFont font;
int begin;
int timer = 30; // time 
int duration = 30; // duration 

int texty = 350; //the initial position of the text for credits 
PImage background_img;
boolean displayCredits = false;
int score = 0; // player score

int count = 20; // number of bullets

// game state variables
int gameState;
public final int INTRO = 1;
public final int PLAY = 2;
public final int PAUSE = 3;
public final int GAMEOVER = 4;
public final int CREDITS = 5;

void setup()
{
 background(0);
 size(800,500);
 font = createFont("Cambria", 32); 
 frameRate(24);
 
 asteroidPic = loadImage("asteroid.png");
 rocket = loadImage("rocket.png");
 
 asteroids = new ArrayList<Asteroid>(0);
 
 gameState = INTRO;
}

void draw()
{  
  switch(gameState) 
  {
    case INTRO:
      drawScreen("Welcome!", "Press s to start");
      break;
    case PAUSE:
      drawScreen("PAUSED", "Press p to resume");
      break;
    case GAMEOVER:
      drawScreen("GAME OVER", "Press s to try again");
      music.stop();
      break;
    case CREDITS:
      drawCredits(); // function call for credits
      break;
    case PLAY:
      background(0);
      timer(); // function call to timer
      score(); // function call to score
      bullet_count(); // bullet count 
      
      ship.update();
      ship.render(); 
              
      if(ship.checkCollision(asteroids) || asteroids.size() <=0 || timer == 0)
             gameState = GAMEOVER;
      else
      {                    
          for(int i = 0; i < bullets.size(); i++)
          {    
             bullets.get(i).update();
             bullets.get(i).render();
    
            if(bullets.get(i).checkCollision(asteroids))
            {
              if (score % 3 == 0) // bonus if score has no remainder asteroid is destroyed
              {
                count = count + 3; // add three bullets
                score += 10;
              }
              else 
              score += 10; // hit player get 10 points
               bullets.remove(i);
               i--;
            }                        
          }
     
 
          for(int i=0; i<asteroids.size(); i++)//(Asteroid a : asteroids)
          {
             asteroids.get(i).update();            
             asteroids.get(i).render(); 
          }
          
         float theta = heading2D(ship.rotation)+PI/2;    
             
         if(leftPressed)
            rotate2D(ship.rotation,-radians(5));
        
         if(rightPressed)
            rotate2D(ship.rotation, radians(5));
   
         if(upPressed)
         {
            ship.acceleration = new PVector(0,shipSpeed); 
            rotate2D(ship.acceleration, theta);
         }    
          
       }
       break;
  }
 
}

//Initialize the game settings. Create ship, bullets, and asteroids
void initializeGame() 
{
  
   music = new SoundFile(this, "MENU A - Back.wav"); // sound for bullets 
   music.loop();
  
   ship  = new Ship();
   bullets = new ArrayList<Bullet>();   
   asteroids = new ArrayList<Asteroid>();
   
   begin = millis(); // timer
   
   for(int i = 0; i <numAsteroids; i++)
   {
      PVector position = new PVector((int)(Math.random()*width), 50);      
      asteroids.add(new Asteroid(position, startingRadius, asteroidPic));
   }
}


//
void fireBullet()
{ 
  bullet_sound = new SoundFile(this, "laser8.wav"); // sound for bullets 
  bullet_sound.play();

  println("fire");//this line is for debugging purpose

  PVector pos = new PVector(0, ship.r*2);
  rotate2D(pos,heading2D(ship.rotation) + PI/2);
  pos.add(ship.position);
  PVector vel  = new PVector(0, bulletSpeed);
  rotate2D(vel, heading2D(ship.rotation) + PI/2);
  
  if (count > 1)
  {
  bullets.add(new Bullet(pos, vel)); // add a bullet
  count--; // remove one bullet from total ammo
  }
  else{
    gameState=GAMEOVER; // ran out of bullets gameover 
  }
}

void keyPressed()
{ 
  if(key== 's' && ( gameState==INTRO || gameState==GAMEOVER )) 
  {
    initializeGame();  
    gameState=PLAY; 
    timer = 30;
    duration = 30;
    score = 0;
  }
  
  // pause screen
  if(key=='p' && gameState==PLAY)
    gameState=PAUSE;
  else if(key=='p' && gameState==PAUSE)
    gameState=PLAY;
    
    // credits screen
    if(key=='c' && gameState==PLAY)
    gameState=CREDITS;
  else if(key=='c' && gameState==CREDITS)
    gameState=PLAY;
  
  
  //when space key is pressed, fire a bullet
  if(key == ' ' && gameState == PLAY)
     fireBullet();
   
   
  if(key==CODED && gameState == PLAY)
  {         
     if(keyCode==UP) 
       upPressed=true;
     else if(keyCode==DOWN)
       downPressed=true;
     else if(keyCode == LEFT)
       leftPressed = true;  
     else if(keyCode==RIGHT)
       rightPressed = true;        
  }

}
 

void keyReleased()
{
  if(key==CODED)
  {
   if(keyCode==UP)
   {
     upPressed=false;
     ship.acceleration = new PVector(0,0);  
   } 
   else if(keyCode==DOWN)
   {
     downPressed=false;
     ship.acceleration = new PVector(0,0); 
   } 
   else if(keyCode==LEFT)
      leftPressed = false; 
   else if(keyCode==RIGHT)
      rightPressed = false;           
  } 
}


void drawScreen(String title, String instructions) 
{
  background(0,0,0);
  
  // draw title
  fill(255,100,0);
  textSize(60);
  textAlign(CENTER, BOTTOM);
  text(title, width/2, height/2);
  
  // draw instructions
  fill(255,255,255);
  textSize(32);
  textAlign(CENTER, TOP);
  text(instructions, width/2, height/2);
}



float heading2D(PVector pvect)
{
   return (float)(Math.atan2(pvect.y, pvect.x));  
}


void rotate2D(PVector v, float theta) 
{
  float xTemp = v.x;
  v.x = v.x*cos(theta) - v.y*sin(theta);
  v.y = xTemp*sin(theta) + v.y*cos(theta);
}
void drawCredits() 
{
  background_img = loadImage("bricks.jpg");
  image(background_img, 130, 100);  //set the image as background
  textAlign(CENTER);
  textSize(22);  
  fill(0); //text color
  text("Asteroids game made by \n" + 
       "Programmer: Donald Mathews \n" +
       "Background Animation: Donald Mathews \n" + 
       "Thank You for playing!", 
        width/2, texty);
        
  texty -= 1;  
}
void timer() // timer function for countdown 
{
  if (timer > 0) 
  {
    timer = duration - (millis() - begin) / 1000;
    fill(255);
    text("Time:" + timer, 80, 80);
  }
}
void score() // score function 
{
  fill(255);
  text("Score:"+ score,600, 80);
  
}
void bullet_count() // bullet count function
{
  fill(255);
  text("Bullets:" + count,400,80);
}
  
