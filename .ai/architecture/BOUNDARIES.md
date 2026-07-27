# Architecture Boundaries

## Presentation
รับ input แสดง state และเรียก application use case เท่านั้น

## Application
จัด orchestration, authorization, transaction boundary, preview/apply workflow

## Domain
เก็บ invariant, entities, value objects, rules, conflict and policy decisions

## Infrastructure
เชื่อม local storage, file system, Google APIs, PDF/printing, notifications และ backup

## Dependency direction
Presentation → Application → Domain
Infrastructure implements interfaces defined inward; Domain ห้าม import Flutter หรือ external SDK
