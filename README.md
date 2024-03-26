# spaceship
First Gameboy DMG Homebrew game

## Building

```
wla-gb game.asm
wla-link game.link game.gb
```

## Instructions

D-PAD to move around, Push A to spawn bullets.
That's about it...

## Post-Mortem

The code is kind of a mess and it gets hard
to extend and work with. Here are some reasons
I suppose this is the case.

**Stylistic**
* We're not programming BASIC anymore. We're allowed
  to have mixed casing and this makes it so that words
  in the labels don't blend as much together.
* Inline comments should be preferred so that the Instructions
  stream smoother than they actually did.
* A macro for each ``RST`` routine would've been very helpful.
  It gets really confusing really quickly what ``RST`` routine does
  what without being able to see the names I've assigned them.

**Technical**
* Using an ``SOA``-style for storing the positions and ``OAM`` addrs
  of entities was a good idea. It made both of them much easier
  to index individually. Perhaps I should've also split up positions
  into X and Y arrays.
* Arrays should be 256-byte aligned when possible because
  this makes indexing easier as the scaling can be done in
  ``A`` which can then be loaded immediately into the low byte.
  This also removes the need for any additions.
* Arrays should not cross 256-byte pages when possible.
  Similar reasoning to being 256-byte aligned.
* Common aggregates like position in this game should be accessed by
  function so that scaling the index doesn't have to be inlined every time.
* Common calling conventions should be defined instead of having ad-hoc
  ones like I did here. The exception is ``RST`` routines. They're special
  and few enough to justify the assumptions I made for them.
  - Because deep call stacks aren't common, a good one is
    to assume that all registers are volatile and that 
  - arguments are passed into ``A``, ``HL``, ``DE``, ``BC``
* Symbol files would have been extremely helpful. I don't know how 
  to port them from ``WLA`` to ``BGB`` emulator. I really should learn this.
* ``WLA`` might have a way to eliminate some of the magic numbers I have.
  IDK. I should learn the assembler.
  - I could also consider maintaining the ``Z80`` target for GNU ``binutils``
    in my free time. These are build tools I know. The problem is that such
    tools aren't common to emulators so they'd likely be harder to debug...
    Similar case with ``65XX`` targets.
