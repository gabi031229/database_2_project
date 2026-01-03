Delivery Handler – adatbázis projekt

A projektemben egy futárcég leegyszerűsített adatbázismodelljét valósítottam meg.
A cél nem egy teljes, éles rendszer felépítése volt, hanem egy jól strukturált, gyakorlatban is értelmezhető adatbázis készítése, amely bemutatja egy csomagküldő szolgáltatás alapvető működését.

Az adatmodell kezeli:

ügyfeleket (feladó, címzett),
csomagokat és azok státuszait,
csomagautomatákat és futárokat,
eseményeket (tracking),
valamint a fizetések alapadatait.

A táblák technikai mezőkkel egészülnek ki (created_on, created_by, version, stb.), a változások naplózására history táblák és triggerek szolgálnak.
Az üzleti logika PL/SQL package-ekbe van szervezve, a hibák pedig naplózásra kerülnek, nem csak továbbdobásra.
