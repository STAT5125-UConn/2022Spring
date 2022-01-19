## The Joy of Julia

You can fully appreciate it (actually it is an animation of revolving hearts) when you run the code yourself. You can find it [here](https://github.com/maxbennedich/code-golf/tree/cea06287689868f2342959f9c12f0b629a1d0cf4/hearts).

Please make sure that you run the code on a fast terminal with font that supports Unicode (for instance under Windows I can recommend [ConEmu](https://conemu.github.io/).

```julia
0:2e-3:2π.|>d->((P=fill(5<<11,64,25))[64,:].=10;z=8cis(d)sin(.46d);for r=0:98,c=0:5^3 x,y=@.mod(2-$reim((.016c-r/49im-1-im)z),4)-2;√2(y+.5-√√x^2)^2<4-x^2&&(P[c÷2+1,r÷4+1]|=Int(")*,h08H¨"[1+r&3+4&4c])-40)end;print("\e[H\e[1;31m",join(Char.(P))));
```
