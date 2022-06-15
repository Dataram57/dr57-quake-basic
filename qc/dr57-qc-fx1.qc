string FX_PARTICLE_MDL0="progs/s_dotsml_wht.spr";
string FX_PARTICLE_MDL1="progs/s_dotsml_wht.spr";
string FX_PARTICLE_MDL2="progs/s_dotsml_red.spr";
int FX_DEFAULT_COUNT=0;

/*
-----------------
|               |
|     Basic     |
|               |
-----------------
*/

//precache
void() fx_precache=
{
    precache_model(FX_PARTICLE_MDL1);
    precache_model(FX_PARTICLE_MDL2);
}

string(float skin) fx_get_particle_model=
{
    skin=skin+1;
    if(skin==1) return FX_PARTICLE_MDL1;
    if(skin==2) return FX_PARTICLE_MDL2;
    return FX_PARTICLE_MDL0;
}

void(entity p,float skin) fx_apply_particle_model=
{
    setmodel(p,fx_get_particle_model(skin));
}

//particle object
void() fx_particle =
{
    //self.chain    next particle
    fx_precache();
	//model is going to be set once on think method of pool
    //setmodel (self, FX_PARTICLE_MDL);
}

//returns clean particle object(doesn't belong to any chain)
entity(float skin) fx_spawn_particle =
{
    local entity t;
    t=spawn();
    t.classname="fx_particle";
    //setmodel (t, FX_PARTICLE_MDL);
    fx_apply_particle_model(t,skin);

    //assign special properties
    t.size=(0,0,0);
    t.size.x=random();
    t.size.y=random();
    t.size.z=random();
    return t;
}

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
    //dprint(vtos(t_first.size));
}

//use the ring of particles
/*
entity(entity pool) fx_get_next_particle_from_pool={
    pool.chain=pool.chain.chain;
    return pool.chain;
}/**/

void() fx_particle_pool{
    //apply model
    local entity t,t_first;
    t_first=self.chain;
    while(t)
    {
        fx_apply_particle_model(t,self.skin);
    }
}


//this function/method tells whether to group or not to group the provided fogbox with provided pool
float(entity fogbox,entity pool) fx_compare_fogbox_pool=
{
    if(fogbox.style!=pool.style) return FALSE;       //Mathematical position algorithm
    if(fogbox.skin!=pool.skin) return FALSE;         //Model of the particle or skin
    if(fogbox.speed!=pool.speed) return FALSE;       //Speed of time(time multiplier)
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
    p.count=self.count;
    p.style=self.style;
    p.skin=self.skin;
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
*/
vector FX_FOGBOX_SIZE=(256,256,256);

void() fx_fogbox_think=
{
    local entity t;
    local float i,f,c;
    local vector vt=find(world,classname,"player").origin;
    if(TRUE)
    {
        dprint("\n");
        dprint(vtos(vt));
    }

    local vector a,b;

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
    dprint("\n");
    dprint(self.targetname);
    dprint(" read: ");
    dprint(ftos(i));
    while(i>0)
    {
        //get position
        a=t.v_angle;

        //try to set (doesn't matter if it has been already transformed)
        if(v_in_box(a,self.origin,self.size))
        {
            t.origin=a;
        }

        //next
        i=i-1;

        //get next particle
        t=t.chain;
    }

    //scan (don't consider calculation of the position)
    i=fpos(self.count-f);          //number of particles left to calculate
    dprint("\n");
    dprint(self.targetname);
    dprint(" calc: ");
    dprint(ftos(i));
    f=0;

    if(TRUE)
    {
        dprint("\n");
        dprint(vtos(vt));
    }
    while(i>0)
    {
        //calc position
        a=vt + FX_FOGBOX_SIZE / 2;
        b=vmulti(FX_FOGBOX_SIZE , t.size);
        //movement
        if(self.style==0)
            b.z=b.z-time*64;

        //fit
        a=vmulti(vfloor(vdiv(a - b , FX_FOGBOX_SIZE)) , FX_FOGBOX_SIZE);
        a=a+b;

        //save calculated position
        t.v_angle=a;

        //try to set
        if(v_in_box(a,self.origin,self.size))
        {
            t.origin=a;
            f=f+1;
        }
        else
        {
            //make invisible
            t.origin=(0,0,0);
        }

        //next
        i=i-1;

        //get next particle
        t=t.chain;
    }
    dprint("\n");
    dprint(self.targetname);
    dprint(" tran: ");
    dprint(ftos(f));

    //try to update number of calculated particles
    if(self.chain.count<self.count)
        self.chain.count=self.count;
    
    //next update
    self.nextthink=time+0.01;
}

void() fx_fogbox_think_init=
{

    //connect to the ring of particles
    self.chain=fx_get_particle_pool();

    //start loop
    self.think=fx_fogbox_think;
    self.nextthink=time+0.01;
}
//particle (self.origin, '0 0 0', 75, 255);

void() fx_fogbox=
{
    fx_precache();

    //calculate center and size of the box
    setmodel (self, self.model);	// set size and link into world
    self.modelindex = 0;
	self.model = "";
    self.origin=(self.absmax+self.absmin)/2;        //center
    self.size=vabs(self.absmax-self.absmin)/2;      //size

    if(self.think) return;  //cause all is already set

    //setup
    self.think=fx_fogbox_think_init;
    self.nextthink=time+0.01;
}
