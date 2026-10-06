---
name: hub_kernel-info
description: Use to learn what hub_kernel offers — hubs, the ports a hub declares, the methods it lets outside callers reach by name, and the checks that a host app has filled every hub and that no hub reaches into another.
tools: Read
scope: hubs — a domain gem declares the ports it needs and the methods it exposes, and the host app fills those ports and checks each hub is wired and crosses into no other hub
---

This local explains hub_kernel and the words it uses. It makes no changes and gives no steps.

## What hub_kernel is

hub_kernel splits a Rails app into hubs, where each hub is one area of the domain, such as supplies or finance, usually shipped in its own domain gem. A hub states what it needs from outside itself as named ports, and the host app decides what fills each one, so a hub never names another hub's code directly.

A hub also lists the methods outside callers may reach by name, with the values each takes and whether it writes. An interface such as a JSON API calls through that list, and every call is checked against the host's permission rule and run inside the host's account scope. Reach for hub_kernel when an app has several domain areas that should talk to each other only through declared entry points, and you want the app to refuse to start, or the suite to fail, when that is not true.

## Interface

This local documents no commands. The surface belongs to the other two locals:

- **hub_kernel-install** owns everything the host app does: adding the gem, filling each hub's ports, running the start check, setting the permission rule and the account scope, and adding the hub check and the crossing check to the host's tests.
- **hub_kernel-develop** owns everything a hub's author does: generating a hub, declaring its ports, listing the methods callers may reach by name, refusing a request, and adding the check that the listed methods match the hub's real methods.

## How to use it

Decide which side you are on:

- You are wiring hubs into an app, or the app will not start because something is not wired: use **hub_kernel-install**.
- You are writing or changing a hub, inside a domain gem or the app: use **hub_kernel-develop**.

## Conventions

- **Hub** — one domain area, written as a module. In a domain gem it sits under the gem's namespace, such as Billing::Ledger.
- **Ports** — what a hub needs from outside. Each has a name and the method the hub's own code calls, such as a spend recorder called as record_spend.
- **Filling ports** — the host app sets each of a hub's ports to any callable, usually another hub's method, in its setup that runs again on every code reload. Ports are "wired" once they are filled.
- **Start check** — the app refuses to start while any hub's ports are not wired, and names each one, such as "Supplies' spend recorder is not wired".
- **Hub check** — a host test that fails naming each of a hub's ports left unfilled or filled with something that cannot be called. A domain gem never runs it, since the gem never fills its own ports.
- **Call by name** — a caller reaches a hub method by its name as a string, with the values sent, the person, and the account. Unknown names, a missing person or account, and missing required values are refused.
- **Action** — the name a permission is asked for, made of the hub and the method, such as supplies:record_purchase.
- **Permission check** — one host-wide rule answering true or false for a person, an action, and an account. Any other answer is an error.
- **Account scope** — one host-wide wrapper that runs each call by name inside the account it was made for.
- **Refusing** — what a hub does when it will not do what was asked, and its reason reaches the caller unchanged.
- **Crossing** — a file in one hub naming a class another hub owns. A constant inside that class counts.
- **Crossing map** — the host's statement of which classes each hub owns, plus the classes shared by all, the host's own layer, each hub's interface module, and any namespace a hub owns whole. Only the host's layer may name a hub's interface module, and a view belongs to the hub that owns its controller.
