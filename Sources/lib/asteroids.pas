unit asteroids;

interface

uses
  System.SysUtils,
  winapi.windows,
  tpvector2d_unit,
  AG.Types,
  AG.Graphic,
  AG.Windows;

type
  asteroid = record
    pos,vel,acc:tpvector2d;
    radius:real;
    s:real;
    color:integer;
  end;

  asteroid_system = record
    list_of_asteroids:array of asteroid;
    g:real;
  end;

var
  m:msg;
  wndcoord:TAGScreenCoord;
  brush:array[0..10] of TAGBrush;
  br:TAGBrush;
  p:TAGScreenvector;
  system:asteroid_system;
  t,wait:cardinal;
  Fwait:boolean;

function my_random(min,max:integer):integer;inline;
procedure move(var asteroid1:asteroid);inline;
function get_acc(asteroid1:asteroid; system:asteroid_system):tpvector2d;inline;
function collision(asteroid1,asteroid2 : asteroid):boolean;inline;
function inelastic(asteroid1,asteroid2:asteroid):asteroid;inline;
procedure do_collision(var system:asteroid_system);inline;
procedure generate(n:word);inline;



implementation

function my_random(min,max:integer):integer;
begin
  Result:=min+random(max-min);
end;

procedure move(var asteroid1:asteroid);
begin
  asteroid1.pos := add(asteroid1.pos, asteroid1.vel);
  asteroid1.vel := add(asteroid1.acc, asteroid1.vel);
  if asteroid1.pos.X < asteroid1.radius then
  begin
    asteroid1.pos.X := asteroid1.radius;
    asteroid1.vel.X := -asteroid1.vel.X/4;
  end
  else
  begin
    if asteroid1.pos.X > wndcoord.W-asteroid1.radius then
    begin
      asteroid1.pos.X := wndcoord.W-asteroid1.radius;
      asteroid1.vel.X := -asteroid1.vel.X/4;
    end;
  end;
  if asteroid1.pos.Y < asteroid1.radius then
  begin
    asteroid1.pos.Y := asteroid1.radius;
    asteroid1.vel.Y := -asteroid1.vel.Y/4;
  end
  else
  begin
    if asteroid1.pos.Y > wndcoord.H-asteroid1.radius then
    begin
      asteroid1.pos.Y := wndcoord.H-asteroid1.radius;
      asteroid1.vel.Y := -asteroid1.vel.Y/4;
    end;
  end;
end;

function get_acc(asteroid1:asteroid; system:asteroid_system):tpvector2d;
var
  i:integer;
  y:asteroid;
  difference:tpvector2d;
  j:real;
begin
   result.X := 0;
   result.Y := 0;
   for i := 0 to length(system.list_of_asteroids)-1 do
   begin
    y := system.list_of_asteroids[i];
    difference := sub(y.pos, asteroid1.pos);
    j := get_mag_square(difference);
    if j >=16 then
    begin
    result:=add(result,change_mag(difference, sqr(y.radius)*system.g/j));
    end;
   end;
end;

function collision(asteroid1,asteroid2 : asteroid):boolean;
var
  difference_vec:tpvector2d;
begin
  difference_vec := sub(asteroid1.pos, asteroid2.pos);
  collision := get_mag_square(difference_vec) <= sqr(asteroid1.radius + asteroid2.radius);
end;

function inelastic(asteroid1,asteroid2:asteroid):asteroid;
begin
  if sqr(asteroid1.radius) >= sqr(asteroid2.radius) then
  begin
    inelastic.pos := asteroid1.pos;
  end
  else
  begin
    inelastic.pos := asteroid2.pos;
  end;
  inelastic.vel := mult(add(mult(asteroid1.vel,sqr(asteroid1.radius)),mult(asteroid2.vel,sqr(asteroid2.radius))), 1/(sqr(asteroid1.radius) + sqr(asteroid2.radius)));
  inelastic.radius := sqrt(sqr(asteroid1.radius)+sqr(asteroid2.radius));
  inelastic.color := asteroid1.color;
end;

procedure do_collision(var system:asteroid_system);
var
  i,j,i0,arrsize:integer;
  new_asteroid:asteroid;
begin
  for i := 0 to length(asteroids.system.list_of_asteroids)-2 do
    for j:=i+1 to length(asteroids.system.list_of_asteroids)-1 do
    begin
      if collision(asteroids.system.list_of_asteroids[i],asteroids.system.list_of_asteroids[j]) then
      begin
        asteroids.system.list_of_asteroids[i] := inelastic(asteroids.system.list_of_asteroids[i],asteroids.system.list_of_asteroids[j]);
          arrsize:= length(asteroids.system.list_of_asteroids);
          for i0:=j to arrsize-2 do
          begin
            asteroids.system.list_of_asteroids[i0]:=asteroids.system.list_of_asteroids[i0+1];
          end;
          setlength(asteroids.system.list_of_asteroids,arrsize-1);
      end;
    end;
end;

procedure generate(n:word);
var
  i:integer;
begin
  setlength(asteroids.system.list_of_asteroids,n);
  for i := 0 to n - 1 do
  begin
    asteroids.system.list_of_asteroids[i].pos.Y := my_random(10,wndcoord.H - 10);
    asteroids.system.list_of_asteroids[i].pos.X := my_random(10,wndcoord.W - 10);
    asteroids.system.list_of_asteroids[i].radius := my_random(2,3);
    asteroids.system.list_of_asteroids[i].s:=sqr(asteroids.system.list_of_asteroids[i].radius);
    asteroids.system.list_of_asteroids[i].vel.Y := 0;
    asteroids.system.list_of_asteroids[i].vel.X := 0;
    asteroids.system.list_of_asteroids[i].acc.Y := 0;
    asteroids.system.list_of_asteroids[i].acc.X := 0;
    asteroids.system.list_of_asteroids[i].color := my_random(0,9);
  end;
end;


end.