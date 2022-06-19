/*
-----------------
|               |
|  fx_particle  |
|               |
-----------------
-oldorigin          random vector
-chain              next particle (from the pool)
*/

string(float skin) fx_get_particle_model=
{
    if(skin==0) return "progs/s_dotmed_blue.spr";
    if(skin==1) return "progs/s_dotmed_dblue.spr";
    if(skin==2) return "progs/s_dotmed_grey.spr";
    if(skin==3) return "progs/s_dotmed_grn.spr";
    if(skin==4) return "progs/s_dotmed_lgrn.spr";
    if(skin==5) return "progs/s_dotmed_red.spr";
    if(skin==6) return "progs/s_dotmed_yell.spr";
    if(skin==7) return "progs/s_dotsml_blue.spr";
    if(skin==8) return "progs/s_dotsml_dblue.spr";
    if(skin==9) return "progs/s_dotsml_gold.spr";
    if(skin==10) return "progs/s_dotsml_grey.spr";
    if(skin==11) return "progs/s_dotsml_grn.spr";
    if(skin==12) return "progs/s_dotsml_lgrn.spr";
    if(skin==13) return "progs/s_dotsml_red.spr";
    if(skin==14) return "progs/s_dotsml_wht.spr";
    if(skin==15) return "progs/s_dotsml_yell.spr";
    return "progs/s_dotmed_blue.spr";
}

void() fx_fogbox_precache=
{
    //depends on what style is going to be used, there may be more than 2 models to be used
    
    //standard requirements
    precache_model(fx_get_particle_model(self.skin));
}

//particle object
void() fx_particle = {}

//returns clean particle object(doesn't belong to any chain)
entity(float skin) fx_spawn_particle =
{
    local entity t;
    t=spawn();
    t.classname="fx_particle";

    //assign special properties
    t.oldorigin=(0,0,0);
    t.oldorigin.x=random();
    t.oldorigin.y=random();
    t.oldorigin.z=random();
    t.oldorigin=t.oldorigin * 2 - (1,1,1);
    return t;
}


/*
-----------------
|               |
|    Fx_Pool    |
|               |
-----------------
*style              Algorithm which controls the particles                          (Used for pool grouping)
*count              Maximum number of particles to be displayed (only at start)     (Used for pool grouping)
                    Number of already calculated particles      (only at update)
*skin               Color of the particle                                           (Used for pool grouping)
*chain              Reference to the particle of the pool(ring)
*goalentity         Reference to the next pool
*/


void() fx_particle_pool_think=
{
    //apply model
    local entity t,t_first;
    local float i=0;
    t_first=self.chain;
    t=t_first;
    do
    {
        setmodel(t,fx_get_particle_model(self.skin));
        t=t.chain;
        i=i+1;
    }
    while(t!=t_first);
    self.think=SUB_Null;
}

float FX_POOL_START_TIME=0.01;

//setup ring of particles on a specific object
void(entity pool) fx_setup_particle_pool =
{
    local entity t_last;
    local entity t_new;
    local entity t_first;
    local float i;
    
    //create 1 way ring
    t_first=fx_spawn_particle(pool.skin);
    t_last=t_first;
    i=pool.count;
    while(i>1)
    {
        t_new=fx_spawn_particle(pool.skin);
        t_last.chain=t_new;
        t_last=t_new;
        i=i-1;
    }
    t_last.chain=t_first;
    pool.chain=t_first;

    //Model set
    pool.think=fx_particle_pool_think;
    pool.nextthink=time+FX_POOL_START_TIME;
}

//use the ring of particles
/*
entity(entity pool) fx_get_next_particle_from_pool={
    pool.chain=pool.chain.chain;
    return pool.chain;
}/**/

/*
void() fx_particle_pool=
{
    //precache model
    precache_model(fx_get_particle_model(self.skin));
    
    self.think=fx_particle_pool_think;
    self.nextthink=time+1;
}
*/

//this function/method tells whether to group or not to group the provided fogbox with provided pool
float(entity fogbox,entity pool) fx_compare_fogbox_pool=
{
    if(fogbox.style!=pool.style) return FALSE;           //Mathematical position algorithm
    if(fogbox.v_angle!=pool.v_angle) return FALSE;       //Parameters of this algorithm
    if(fogbox.speed!=pool.speed) return FALSE;       //Speed of the animation
    if(fogbox.skin!=pool.skin) return FALSE;             //Model of the particle or skin of the model
    if(fogbox.view_ofs!=pool.view_ofs) return FALSE;     //Size of the box surrouding the player
    return TRUE;
}

entity() fx_get_particle_pool=
{
    local entity t,p,p_last,p_first;
    local float i;

    //try to find the first pool that leads to other pools
    t=find(world, classname, "fx_particle_pool");

    if(t)
    {
        //check existing pools
        while(TRUE)
        {
            //check if the requester will use existing pool
            if(fx_compare_fogbox_pool(self,t))
            {
                //correct requirements
                if(self.count>t.count)
                {
                    //add more particles to fill the requirements

                    //find last particle
                    i=t.count-1;
                    p_first=t.chain;
                    p_last=p_first;
                    while(i>0)
                    {
                        //get next particle
                        p_last=p_last.chain;

                        //next
                        i=i-1;
                    }
                    
                    //add more
                    i=self.count-t.count;
                    while(i>0)
                    {
                        //create
                        p=fx_spawn_particle(t.skin);
                        p_last.chain=p;
                        p_last=p;
                        
                        //next
                        i=i-1;
                    }
                    p_last.chain=p_first;    //close ring

                    //update count
                    t.count=self.count;
                }

                return t;
            }
            if(t.goalentity)
                t=t.goalentity;
            else
                break;
        }
    }

    //create new pool
    p=spawn();
    p.classname="fx_particle_pool";
    p.style=self.style;
    p.v_angle=self.v_angle;
    p.speed=self.speed;
    p.count=self.count;
    p.skin=self.skin;
    p.view_ofs=self.view_ofs;

    //skin
    fx_setup_particle_pool(p);

    //assign pool to the chain of pools
    if(t) t.goalentity=p;

    return p;
}

/*
-----------------
|               |
|     FogBox    |
|               |
-----------------
-style              Algorithm which controls the particles
-v_angle            Style parameters
-spped              Speed of the animation
-count              Maximum number of particles to be displayed/calculated
-skin               Color of the particle
-view_ofs           Minimum size of the fogbox
*origin             center of the box
*size               size of the box
*/
float FX_FOGBOX_START_TIME=0.01;
float FX_FOGBOX_UPDATE_TIME=0.01;
vector FX_FOGBOX_DEFAULT_SIZE='512 512 512';

void() fx_fogbox_think=
{
    local entity t;
    local float i,f;
    local vector vt=find(world,classname,"player").origin;
    local vector a,b,c;
    
    //reset .count on every cycle
    if(self.chain.cnt!=time)
    {
        self.chain.cnt=time;
        self.chain.count=0;
        f=0;
    }
    else
        f=self.chain.count;           //get number of already calculated particles

    //scan already calculated
    i=fmin(self.count,f); //number of particles that are already calculated and will be used
    t=self.chain.chain;         //set t to the first particle of the pool
    while(i>0)
    {
        //get position
        a=t.v_angle;

        //try to set (doesn't matter if it has been already transformed)
        if(v_in_box(a,self.origin,self.size))
        {
            //t.origin=a;
            setorigin(t,a);
            //t.absmax=a;
            //t.absmin=a;
        }

        //next
        i=i-1;

        //get next particle
        t=t.chain;
    }

    
    if(self.chain.count<self.count)
    {
        //number of particles left to calculate
        i=fpos(self.count-f);

        //calculate constant
        if(self.style==3)
        {
            f=time * self.speed;
            //sphere movement
            c=(0,0,0);
            c.z=farsin(f);
            c.x=farcos(f);
            c.y=farcos(f);
        }

        //scan (don't consider calculation of the position)
        while(i>0)
        {
            //calc position
            a=vt + self.view_ofs / 2;
            b=vmulti(self.view_ofs , vabs(t.oldorigin));

            //movement
            if(self.style==1)       //Move by vector
            {
                b=b + self.v_angle * time;
                //b=vadd(b,self.angle_v * time * self.speed);
            }
            else if(self.style==2)
            {
                f=time * self.speed + 360 * t.oldorigin.z;
                //sphere movement
                c=(0,0,0);

                //X Z
                c.z=farsin(f);
                c.x=farcos(f);
                c.y=farsin(f + 360 * t.oldorigin.y);
                //c.y=farcos(f);
                b=b + vmulti(self.v_angle,vmulti(c,vsign(t.oldorigin)));
            }
            else if(self.style==3)
            {
                b=b + vmulti(self.v_angle,vmulti(c,vsign(t.oldorigin)));
            }
            else if(self.style==4)
            {
                //update next random pos
                t.oldorigin.x=random();
                t.oldorigin.y=random();
                t.oldorigin.z=random();
                t.oldorigin=t.oldorigin * 2 - '1 1 1';
            }


            //fit
            a=vmulti(vfloor(vdiv(a - b , self.view_ofs)) , self.view_ofs);
            a=a+b;

            //save calculated position
            t.v_angle=a;

            //try to set
            if(v_in_box(a,self.origin,self.size))
            {
                //t.origin=a;
                setorigin(t,a);
                //t.absmax=a;
                //t.absmin=a;
            }
            else
            {
                //make invisible
                //t.origin=(0,0,0);
                setorigin(t,(0,0,0));
            }

            //next
            i=i-1;

            //get next particle
            t=t.chain;
        }

        //try to update number of calculated particles
        self.chain.count=self.count;
    }
    
    //next update
    self.nextthink=time+FX_FOGBOX_UPDATE_TIME;
}

void() fx_fogbox_use=
{
    //disalbe/enable
    local float i;
    local entity t;
    if(self.spawnflags & 1)
    {
        //log
        dprintln("Enabled FogBox ");
        dprint(self.targetname);
        //enable
        i=-1;
        self.think=fx_fogbox_think;
        self.nextthink=time+FX_FOGBOX_UPDATE_TIME;
    }
    else 
    {
        //log
        dprintln("Disabled FogBox ");
        dprint(self.targetname);
        //particles
        i=self.count;
        t=self.chain.chain;
        dprintln(ftos(i));
        while(i>0)
        {
            setorigin(t,(0,0,0));
            t=t.chain;
            i=i-1;
        }
        //disable
        i=1;
        self.think=SUB_Null;
    }
    self.spawnflags=self.spawnflags+i;
}

void() fx_fogbox_think_init=
{
    //connect to the ring of particles
    self.chain=fx_get_particle_pool();

    //set use func
    self.use=fx_fogbox_use;

    //start loop
    self.think=fx_fogbox_think;
    self.nextthink=time+FX_FOGBOX_UPDATE_TIME;
}
//particle (self.origin, '0 0 0', 75, 255);

void() fx_fogbox=
{
    //precache
    fx_fogbox_precache();

    //calculate center and size of the box
    setmodel (self, self.model);	// set size and link into world
    self.modelindex = 0;
	self.model = "";
    self.origin=(self.absmax+self.absmin)/2;        //center
    self.size=vabs(self.absmax-self.absmin)/2;      //size
    if(!self.view_ofs) self.view_ofs=FX_FOGBOX_DEFAULT_SIZE;

    if(self.think) return;  //cause pool is already connected

    //optimize properties
    if(self.style==1)       //Move by vector
    {
        self.v_angle = self.v_angle * self.speed;
        //b=vadd(b,self.angle_v * time * self.speed);
    }

    //setup
    self.think=fx_fogbox_think_init;
    self.nextthink=time+FX_FOGBOX_START_TIME;
}
