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