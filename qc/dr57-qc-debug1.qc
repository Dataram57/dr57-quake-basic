void(string text) dprintln=
{
    dprint("\n");
    dprint(text);
}
void(float f) dprintlnf=
{
    dprint("\n");
    dprint(ftos(f));
}
void(vector v) dprintlnv=
{
    dprint("\n");
    dprint(vtos(v));
}
void(entity who,string name,string val) dprintby=
{
    return;
    dprint("\n");
    dprint(who.targetname);
    dprint(" ");
    dprint(name);
    dprint(": ");
    dprint(val);
}

void() think_log=
{
    dprint("\n");
    dprint(self.targetname);
    dprint(" at ");
    dprint(vtos(self.origin));
    self.nextthink=time+1;
}

void(entity e) setup_think_log=
{
    e.think=think_log;
    e.nextthink=time+1;
}