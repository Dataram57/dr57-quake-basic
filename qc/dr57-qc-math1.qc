vector(vector v) vabs=
{
    v.x=fabs(v.x);
    v.y=fabs(v.y);
    v.z=fabs(v.z);
    return v;
}

vector(vector v) vfloor=
{
    v.x=floor(v.x);
    v.y=floor(v.y);
    v.z=floor(v.z);
    return v;
}

vector(vector a,vector b) vdiv=
{
    a.x=a.x/b.x;
    a.y=a.y/b.y;
    a.z=a.z/b.z;
    return a;
}

vector(vector a,vector b) vmulti=
{
    a.x=a.x*b.x;
    a.y=a.y*b.y;
    a.z=a.z*b.z;
    return a;
}

vector(vector a,vector b) vadd=
{
    a.x=a.x+b.x;
    a.y=a.y+b.y;
    a.z=a.z+b.z;
    return a;
}

vector(vector a,vector b) vmod=
{
    a.x=a.x%b.x;
    a.y=a.y%b.y;
    a.z=a.z%b.z;
    return a;
}

vector(vector a) vcube=
{
    return a*a;
}

float(float a, float b) fmin=
{
    if(a<b) return a;
    return b;
}

float(float a, float b) fmax=
{
    if(a>b) return a;
    return b;
}

float(float a) fsign=
{
    if(a>0) return 1;
    else if (a<0) return -1;
    return 0;
}

vector(vector a) vsign=
{
    a.x=fsign(a.x);
    a.y=fsign(a.y);
    a.z=fsign(a.z);
    return a;
}

float(float a) fpos=
{
    if(a>0) return a;
    return 0;
}

vector(vector target, vector center, vector size) vmin_box =
{
    target=target-center;
    target.x=fmin(fabs(target.x),size.x) * fsign(target.x);
    target.y=fmin(fabs(target.y),size.y) * fsign(target.y); 
    target.z=fmin(fabs(target.z),size.z) * fsign(target.z); 
    return center + target;
}

float(vector target, vector center, vector size) v_in_box =
{
    target=vabs(target-center);
    if(target.x>size.x || target.y>size.y || target.z>size.z)
        return FALSE;
    return TRUE;
}


float(float angle) foptangle=
{
    if(angle>0) return angle % 360;
    return 360 - fabs(angle) % 360;
}

//const
float MATH_FARSIN_CONST=1/90/90;

//angle in degrees
float(float angle) farsin=
{
    //correct angle
    angle=foptangle(angle);
    //get signum of the part angle is on
    local float i = floor(angle/180) * 2 - 1;
    //make angle fit in the equastion
    angle = angle % 180;
    //get angle value
    angle = angle * ( angle  - 180 ) * MATH_FARSIN_CONST;
    //return angle corrected by the - value
    return angle * i;
}

float(float angle) farcos=
{
    return farsin(90+angle);
}

float (vector a, vector b) vvisible =
{
	traceline (a, b, TRUE, self);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};