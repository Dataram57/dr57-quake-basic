static vector v_forward2, v_up2, v_right2;

/*==========
save_vectors
==========*/
static void() save_vectors =
{
    v_forward2 = v_forward;
    v_up2 = v_up;
    v_right2 = v_right;
};

/*==========
restore_vectors
==========*/
static void() restore_vectors = 
{
    v_forward = v_forward2;
    v_up = v_up2;
    v_right = v_right2;    
};

/*==========
cos
==========*/
float(float n) cos =
{
    save_vectors();
    
    vector ang = [0, n, 0];
    makevectors(ang);
    float result = v_forward_x;
    
    restore_vectors();
    return result;
};

/*==========
sin
==========*/
float(float n) sin =
{
    save_vectors();
    
    vector ang = [0, n, 0];
    makevectors(ang);
    float result = v_forward_y;
    
    restore_vectors();
    return result;
};

/*==========
tan
==========*/
float(float n) tan =
{
    save_vectors();
    
    vector ang = [0, n, 0];
    makevectors(ang);
    float result = v_forward_y / v_forward_x;
    
    restore_vectors();
    return result;
};

/*==========
atan2
==========*/
float(float y, float x) atan2 =
{
    vector ang = [x, y, 0];
    return vectoyaw(ang);
};