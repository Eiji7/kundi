# Kundi

Kundi is a simple MMO game.

## The game mechanics

* The game is played in the browser

* The player is assigned a hero which is spawned on a random walkable tile. The hero is assigned a random name. The player can also choose a custom name for their hero

* If a player connects to the game with a name that already exists and is controlled by another player, both players control the same hero. You don’t need to make your game cheat-proof in this regard

* Your hero can move freely over all empty/walkable tiles. They can also walk on tiles where enemies are already standing

* Each hero can attack everyone else within the radius of 1 tile around him (in all directions) + the tile they are standing on. For example, if your hero is standing on tile {2, 3}, they can attack everyone on tiles: {1, 2}, {2, 2}, {3, 2}, {1, 3}, {2, 3}, {3, 3}, {1, 4}, {2, 4}, {3, 4}.

* If there are multiple enemies in range, all of them are attacked at the same time. One hit is enough to kill the enemy.

## Requirements

* Elixir
* Erlang
* Heroku CLI

## Development

Before you start working on code you need to feth project dependencies:

```bash
$ mix deps.get
```

To check your changes localy call:

```bash
$ mix run --no-halt
```

or if you want to have a working `iex` session:

```bash
$ iex -S mix
```

By default `PORT` is set to `4000` to change it simply replace system environment like:

```bash
$ PORT=4001 iex -S mix
```

## Deployment

You need to be looged into `Heroku CLI`.

If your cloned project does not have `heroku` remote you need to add it like:

```bash
$ heroku git:remote -a aqueous-island-85743
```

or using only `git`:

```bash
$ git remote add heroku git@heroku.com:aqueous-island-85743.git
```

To deploy changes simply call `push` to `heroku` like:

```bash
$ git push heroku master
```

## Play

To play locally visit: http://localhost:4000/ page (if you use default port).

To play on `Heroku` visit: https://gentle-brushlands-79650.herokuapp.com/
