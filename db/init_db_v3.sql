TRUNCATE TABLE "alumnos" CASCADE;
TRUNCATE TABLE "asignaturas" CASCADE;
TRUNCATE TABLE "asistencia" CASCADE;
TRUNCATE TABLE "grupos" CASCADE;
TRUNCATE TABLE "personal_edem" CASCADE;
TRUNCATE TABLE "profesores" CASCADE;
TRUNCATE TABLE "rel_alumno_tarea" CASCADE;
TRUNCATE TABLE "rel_alumnos_grupos" CASCADE;
TRUNCATE TABLE "rel_asignaturas_grupos" CASCADE;
TRUNCATE TABLE "rel_personal_grupos" CASCADE;
TRUNCATE TABLE "rel_profesores_asignaturas" CASCADE;
TRUNCATE TABLE "sesiones" CASCADE;
TRUNCATE TABLE "tareas" CASCADE;
TRUNCATE TABLE "ubicaciones" CASCADE;

INSERT INTO "alumnos" ("id_alumno", "nombre", "apellido", "correo", "contrasena", "url_foto") VALUES
('ALU-001', 'Ahsoka', 'Tano', 'ahsoka.tano@edem.es', 'Ahsoka437&', 'https://ui-avatars.com/api/?name=Ahsoka%20Tano&size=200'),
('ALU-002', 'Aladdin', 'Ababwa', 'aladdin.ababwa@edem.es', 'Aladdin_17!', 'https://ui-avatars.com/api/?name=Aladdin%20Ababwa&size=200'),
('ALU-003', 'Anakin', 'Skywalker', 'anakin.skywalker@edem.es', 'Anakin2026&', 'https://ui-avatars.com/api/?name=Anakin%20Skywalker&size=200'),
('ALU-004', 'Angelina', 'Johnson', 'angelina.johnson@edem.es', 'Angelina!53Edem', 'https://ui-avatars.com/api/?name=Angelina%20Johnson&size=200'),
('ALU-005', 'Anna', 'Arendelle', 'anna.arendelle@edem.es', 'Anna2026$', 'https://ui-avatars.com/api/?name=Anna%20Arendelle&size=200'),
('ALU-006', 'Aragorn', 'Elessar', 'aragorn.elessar@edem.es', 'Aragorn768@', 'https://ui-avatars.com/api/?name=Aragorn%20Elessar&size=200'),
('ALU-007', 'Ariel', 'Triton', 'ariel.triton@edem.es', 'Ariel780$', 'https://ui-avatars.com/api/?name=Ariel%20Triton&size=200'),
('ALU-008', 'Arthur', 'Curry', 'arthur.curry@edem.es', 'ArthurUni!', 'https://ui-avatars.com/api/?name=Arthur%20Curry&size=200'),
('ALU-009', 'Arwen', 'Undomiel', 'arwen.undomiel@edem.es', 'Arwen!30Mstr', 'https://ui-avatars.com/api/?name=Arwen%20Undomiel&size=200'),
('ALU-010', 'Arya', 'Stark', 'arya.stark@edem.es', 'Arya_55@', 'https://ui-avatars.com/api/?name=Arya%20Stark&size=200'),
('ALU-011', 'Aurora', 'Rose', 'aurora.rose@edem.es', 'AuroraPass$', 'https://ui-avatars.com/api/?name=Aurora%20Rose&size=200'),
('ALU-012', 'Barbara', 'Gordon', 'barbara.gordon@edem.es', 'BarbaraMstr&', 'https://ui-avatars.com/api/?name=Barbara%20Gordon&size=200'),
('ALU-013', 'Barry', 'Allen', 'barry.allen@edem.es', 'Barry_79&', 'https://ui-avatars.com/api/?name=Barry%20Allen&size=200'),
('ALU-014', 'Bella', 'Beaumont', 'bella.beaumont@edem.es', 'Bella_66$', 'https://ui-avatars.com/api/?name=Bella%20Beaumont&size=200'),
('ALU-015', 'Bilbo', 'Baggins', 'bilbo.baggins@edem.es', 'Bilbo499*', 'https://ui-avatars.com/api/?name=Bilbo%20Baggins&size=200'),
('ALU-016', 'Boromir', 'Denethor', 'boromir.denethor@edem.es', 'Boromir540!', 'https://ui-avatars.com/api/?name=Boromir%20Denethor&size=200'),
('ALU-017', 'Bran', 'Stark', 'bran.stark@edem.es', 'BranUni@', 'https://ui-avatars.com/api/?name=Bran%20Stark&size=200'),
('ALU-018', 'Brienne', 'Tarth', 'brienne.tarth@edem.es', 'Brienne_67@', 'https://ui-avatars.com/api/?name=Brienne%20Tarth&size=200'),
('ALU-019', 'Bruce', 'Banner', 'bruce.banner@edem.es', 'BrucePass&', 'https://ui-avatars.com/api/?name=Bruce%20Banner&size=200'),
('ALU-020', 'Bruce', 'Wayne', 'bruce.wayne@edem.es', 'Bruce2025#', 'https://ui-avatars.com/api/?name=Bruce%20Wayne&size=200'),
('ALU-021', 'Bruno', 'Madrigal', 'bruno.madrigal@edem.es', 'BrunoMstr!', 'https://ui-avatars.com/api/?name=Bruno%20Madrigal&size=200'),
('ALU-022', 'Buzz', 'Lightyear', 'buzz.lightyear@edem.es', 'Buzz#86Pass', 'https://ui-avatars.com/api/?name=Buzz%20Lightyear&size=200'),
('ALU-023', 'Carol', 'Danvers', 'carol.danvers@edem.es', 'Carol530#', 'https://ui-avatars.com/api/?name=Carol%20Danvers&size=200'),
('ALU-024', 'Cassian', 'Andor', 'cassian.andor@edem.es', 'Cassian&5Uni', 'https://ui-avatars.com/api/?name=Cassian%20Andor&size=200'),
('ALU-025', 'Cedric', 'Diggory', 'cedric.diggory@edem.es', 'Cedric_27*', 'https://ui-avatars.com/api/?name=Cedric%20Diggory&size=200'),
('ALU-026', 'Celeborn', 'Lorien', 'celeborn.lorien@edem.es', 'CelebornUni&', 'https://ui-avatars.com/api/?name=Celeborn%20Lorien&size=200'),
('ALU-027', 'Cersei', 'Lannister', 'cersei.lannister@edem.es', 'Cersei_94@', 'https://ui-avatars.com/api/?name=Cersei%20Lannister&size=200'),
('ALU-028', 'Cho', 'Chang', 'cho.chang@edem.es', 'Cho$17Edem', 'https://ui-avatars.com/api/?name=Cho%20Chang&size=200'),
('ALU-029', 'Clark', 'Kent', 'clark.kent@edem.es', 'Clark_91*', 'https://ui-avatars.com/api/?name=Clark%20Kent&size=200'),
('ALU-030', 'Daenerys', 'Targaryen', 'daenerys.targaryen@edem.es', 'Daenerys583@', 'https://ui-avatars.com/api/?name=Daenerys%20Targaryen&size=200'),
('ALU-031', 'Davos', 'Seaworth', 'davos.seaworth@edem.es', 'DavosPass*', 'https://ui-avatars.com/api/?name=Davos%20Seaworth&size=200'),
('ALU-032', 'Dean', 'Thomas', 'dean.thomas@edem.es', 'Dean2026!', 'https://ui-avatars.com/api/?name=Dean%20Thomas&size=200'),
('ALU-033', 'Diana', 'Prince', 'diana.prince@edem.es', 'Diana_37#', 'https://ui-avatars.com/api/?name=Diana%20Prince&size=200'),
('ALU-034', 'Din', 'Djarin', 'din.djarin@edem.es', 'Din_50@', 'https://ui-avatars.com/api/?name=Din%20Djarin&size=200'),
('ALU-035', 'Draco', 'Malfoy', 'draco.malfoy@edem.es', 'Draco@5Mstr', 'https://ui-avatars.com/api/?name=Draco%20Malfoy&size=200'),
('ALU-036', 'Elrond', 'Rivendell', 'elrond.rivendell@edem.es', 'ElrondPass!', 'https://ui-avatars.com/api/?name=Elrond%20Rivendell&size=200'),
('ALU-037', 'Elsa', 'Arendelle', 'elsa.arendelle@edem.es', 'Elsa&192025', 'https://ui-avatars.com/api/?name=Elsa%20Arendelle&size=200'),
('ALU-038', 'Eomer', 'Rohan', 'eomer.rohan@edem.es', 'Eomer262@', 'https://ui-avatars.com/api/?name=Eomer%20Rohan&size=200'),
('ALU-039', 'Eowyn', 'Rohan', 'eowyn.rohan@edem.es', 'Eowyn2026&', 'https://ui-avatars.com/api/?name=Eowyn%20Rohan&size=200'),
('ALU-040', 'Ezra', 'Bridger', 'ezra.bridger@edem.es', 'Ezra_88@', 'https://ui-avatars.com/api/?name=Ezra%20Bridger&size=200'),
('ALU-041', 'Faramir', 'Denethor', 'faramir.denethor@edem.es', 'Faramir2026@', 'https://ui-avatars.com/api/?name=Faramir%20Denethor&size=200'),
('ALU-042', 'Finn', 'Storm', 'finn.storm@edem.es', 'Finn525&', 'https://ui-avatars.com/api/?name=Finn%20Storm&size=200'),
('ALU-043', 'Fred', 'Weasley', 'fred.weasley@edem.es', 'Fred971#', 'https://ui-avatars.com/api/?name=Fred%20Weasley&size=200'),
('ALU-044', 'Frodo', 'Baggins', 'frodo.baggins@edem.es', 'Frodo73!', 'https://ui-avatars.com/api/?name=Frodo%20Baggins&size=200'),
('ALU-045', 'Galadriel', 'Lorien', 'galadriel.lorien@edem.es', 'Galadriel*332026', 'https://ui-avatars.com/api/?name=Galadriel%20Lorien&size=200'),
('ALU-046', 'Gendry', 'Baratheon', 'gendry.baratheon@edem.es', 'Gendry375!', 'https://ui-avatars.com/api/?name=Gendry%20Baratheon&size=200'),
('ALU-047', 'George', 'Weasley', 'george.weasley@edem.es', 'George_17$', 'https://ui-avatars.com/api/?name=George%20Weasley&size=200'),
('ALU-048', 'Gimli', 'Gloin', 'gimli.gloin@edem.es', 'Gimli180@', 'https://ui-avatars.com/api/?name=Gimli%20Gloin&size=200'),
('ALU-049', 'Ginny', 'Weasley', 'ginny.weasley@edem.es', 'GinnyMstr#', 'https://ui-avatars.com/api/?name=Ginny%20Weasley&size=200'),
('ALU-050', 'Haldir', 'Lorien', 'haldir.lorien@edem.es', 'HaldirEdem@', 'https://ui-avatars.com/api/?name=Haldir%20Lorien&size=200'),
('ALU-051', 'Han', 'Solo', 'han.solo@edem.es', 'Han282#', 'https://ui-avatars.com/api/?name=Han%20Solo&size=200'),
('ALU-052', 'Harry', 'Potter', 'harry.potter@edem.es', 'Harry@122026', 'https://ui-avatars.com/api/?name=Harry%20Potter&size=200'),
('ALU-053', 'Hera', 'Syndulla', 'hera.syndulla@edem.es', 'Hera967@', 'https://ui-avatars.com/api/?name=Hera%20Syndulla&size=200'),
('ALU-054', 'Hermione', 'Granger', 'hermione.granger@edem.es', 'HermioneMstr!', 'https://ui-avatars.com/api/?name=Hermione%20Granger&size=200'),
('ALU-055', 'Jaime', 'Lannister', 'jaime.lannister@edem.es', 'Jaime99&', 'https://ui-avatars.com/api/?name=Jaime%20Lannister&size=200'),
('ALU-056', 'Jasmine', 'Sultan', 'jasmine.sultan@edem.es', 'Jasmine_97#', 'https://ui-avatars.com/api/?name=Jasmine%20Sultan&size=200'),
('ALU-057', 'Jon', 'Snow', 'jon.snow@edem.es', 'Jon_94$', 'https://ui-avatars.com/api/?name=Jon%20Snow&size=200'),
('ALU-058', 'Jorah', 'Mormont', 'jorah.mormont@edem.es', 'Jorah#41Mstr', 'https://ui-avatars.com/api/?name=Jorah%20Mormont&size=200'),
('ALU-059', 'Jyn', 'Erso', 'jyn.erso@edem.es', 'Jyn@652026', 'https://ui-avatars.com/api/?name=Jyn%20Erso&size=200'),
('ALU-060', 'Kara', 'Zorel', 'kara.zorel@edem.es', 'Kara&72Mstr', 'https://ui-avatars.com/api/?name=Kara%20Zorel&size=200'),
('ALU-061', 'Katie', 'Bell', 'katie.bell@edem.es', 'Katie_54@', 'https://ui-avatars.com/api/?name=Katie%20Bell&size=200'),
('ALU-062', 'Kylo', 'Ren', 'kylo.ren@edem.es', 'Kylo_57&', 'https://ui-avatars.com/api/?name=Kylo%20Ren&size=200'),
('ALU-063', 'Lando', 'Calrissian', 'lando.calrissian@edem.es', 'Lando_3!', 'https://ui-avatars.com/api/?name=Lando%20Calrissian&size=200'),
('ALU-064', 'Lavender', 'Brown', 'lavender.brown@edem.es', 'Lavender_43*', 'https://ui-avatars.com/api/?name=Lavender%20Brown&size=200'),
('ALU-065', 'Lee', 'Jordan', 'lee.jordan@edem.es', 'Lee_61*', 'https://ui-avatars.com/api/?name=Lee%20Jordan&size=200'),
('ALU-066', 'Legolas', 'Greenleaf', 'legolas.greenleaf@edem.es', 'Legolas104!', 'https://ui-avatars.com/api/?name=Legolas%20Greenleaf&size=200'),
('ALU-067', 'Leia', 'Organa', 'leia.organa@edem.es', 'Leia!65Uni', 'https://ui-avatars.com/api/?name=Leia%20Organa&size=200'),
('ALU-068', 'Luke', 'Skywalker', 'luke.skywalker@edem.es', 'LukeMstr*', 'https://ui-avatars.com/api/?name=Luke%20Skywalker&size=200'),
('ALU-069', 'Luna', 'Lovegood', 'luna.lovegood@edem.es', 'Luna&772025', 'https://ui-avatars.com/api/?name=Luna%20Lovegood&size=200'),
('ALU-070', 'Mace', 'Windu', 'mace.windu@edem.es', 'Mace_80!', 'https://ui-avatars.com/api/?name=Mace%20Windu&size=200'),
('ALU-071', 'Margaery', 'Tyrell', 'margaery.tyrell@edem.es', 'Margaery_27#', 'https://ui-avatars.com/api/?name=Margaery%20Tyrell&size=200'),
('ALU-072', 'Maui', 'Motunui', 'maui.motunui@edem.es', 'Maui933*', 'https://ui-avatars.com/api/?name=Maui%20Motunui&size=200'),
('ALU-073', 'Merida', 'DunBroch', 'merida.dunbroch@edem.es', 'MeridaUni!', 'https://ui-avatars.com/api/?name=Merida%20DunBroch&size=200'),
('ALU-074', 'Merry', 'Brandybuck', 'merry.brandybuck@edem.es', 'Merry321#', 'https://ui-avatars.com/api/?name=Merry%20Brandybuck&size=200'),
('ALU-075', 'Miguel', 'Rivera', 'miguel.rivera@edem.es', 'Miguel_66!', 'https://ui-avatars.com/api/?name=Miguel%20Rivera&size=200'),
('ALU-076', 'Mirabel', 'Madrigal', 'mirabel.madrigal@edem.es', 'Mirabel2026*', 'https://ui-avatars.com/api/?name=Mirabel%20Madrigal&size=200'),
('ALU-077', 'Missandei', 'Naath', 'missandei.naath@edem.es', 'Missandei_4!', 'https://ui-avatars.com/api/?name=Missandei%20Naath&size=200'),
('ALU-078', 'Moana', 'Motunui', 'moana.motunui@edem.es', 'Moana902!', 'https://ui-avatars.com/api/?name=Moana%20Motunui&size=200'),
('ALU-079', 'Mulan', 'Hua', 'mulan.hua@edem.es', 'Mulan#44Uni', 'https://ui-avatars.com/api/?name=Mulan%20Hua&size=200'),
('ALU-080', 'Natasha', 'Romanoff', 'natasha.romanoff@edem.es', 'Natasha_99#', 'https://ui-avatars.com/api/?name=Natasha%20Romanoff&size=200'),
('ALU-081', 'Neville', 'Longbottom', 'neville.longbottom@edem.es', 'Neville@75Pass', 'https://ui-avatars.com/api/?name=Neville%20Longbottom&size=200'),
('ALU-082', 'Oberyn', 'Martell', 'oberyn.martell@edem.es', 'Oberyn884&', 'https://ui-avatars.com/api/?name=Oberyn%20Martell&size=200'),
('ALU-083', 'Obiwan', 'Kenobi', 'obiwan.kenobi@edem.es', 'Obiwan#822025', 'https://ui-avatars.com/api/?name=Obiwan%20Kenobi&size=200'),
('ALU-084', 'Oliver', 'Queen', 'oliver.queen@edem.es', 'Oliver757&', 'https://ui-avatars.com/api/?name=Oliver%20Queen&size=200'),
('ALU-085', 'Oliver', 'Wood', 'oliver.wood@edem.es', 'Oliver420*', 'https://ui-avatars.com/api/?name=Oliver%20Wood&size=200'),
('ALU-086', 'Padma', 'Patil', 'padma.patil@edem.es', 'Padma&65Uni', 'https://ui-avatars.com/api/?name=Padma%20Patil&size=200'),
('ALU-087', 'Padme', 'Amidala', 'padme.amidala@edem.es', 'PadmePass!', 'https://ui-avatars.com/api/?name=Padme%20Amidala&size=200'),
('ALU-088', 'Parvati', 'Patil', 'parvati.patil@edem.es', 'Parvati_64#', 'https://ui-avatars.com/api/?name=Parvati%20Patil&size=200'),
('ALU-089', 'Peter', 'Parker', 'peter.parker@edem.es', 'Peter492*', 'https://ui-avatars.com/api/?name=Peter%20Parker&size=200'),
('ALU-090', 'Pippin', 'Took', 'pippin.took@edem.es', 'Pippin_12#', 'https://ui-avatars.com/api/?name=Pippin%20Took&size=200'),
('ALU-091', 'Pocahontas', 'Powhatan', 'pocahontas.powhatan@edem.es', 'Pocahontas_79#', 'https://ui-avatars.com/api/?name=Pocahontas%20Powhatan&size=200'),
('ALU-092', 'Podrick', 'Payne', 'podrick.payne@edem.es', 'Podrick_31!', 'https://ui-avatars.com/api/?name=Podrick%20Payne&size=200'),
('ALU-093', 'Poe', 'Dameron', 'poe.dameron@edem.es', 'Poe2026#', 'https://ui-avatars.com/api/?name=Poe%20Dameron&size=200'),
('ALU-094', 'Rapunzel', 'Corona', 'rapunzel.corona@edem.es', 'Rapunzel_22!', 'https://ui-avatars.com/api/?name=Rapunzel%20Corona&size=200'),
('ALU-095', 'Raya', 'Kumandra', 'raya.kumandra@edem.es', 'Raya495#', 'https://ui-avatars.com/api/?name=Raya%20Kumandra&size=200'),
('ALU-096', 'Rey', 'Palpatine', 'rey.palpatine@edem.es', 'Rey847*', 'https://ui-avatars.com/api/?name=Rey%20Palpatine&size=200'),
('ALU-097', 'Ron', 'Weasley', 'ron.weasley@edem.es', 'Ron774@', 'https://ui-avatars.com/api/?name=Ron%20Weasley&size=200'),
('ALU-098', 'Rosie', 'Cotton', 'rosie.cotton@edem.es', 'Rosie2026*', 'https://ui-avatars.com/api/?name=Rosie%20Cotton&size=200'),
('ALU-099', 'Sabine', 'Wren', 'sabine.wren@edem.es', 'Sabine&182026', 'https://ui-avatars.com/api/?name=Sabine%20Wren&size=200'),
('ALU-100', 'Samwell', 'Tarly', 'samwell.tarly@edem.es', 'Samwell_69$', 'https://ui-avatars.com/api/?name=Samwell%20Tarly&size=200'),
('ALU-101', 'Samwise', 'Gamgee', 'samwise.gamgee@edem.es', 'Samwise365$', 'https://ui-avatars.com/api/?name=Samwise%20Gamgee&size=200'),
('ALU-102', 'Sansa', 'Stark', 'sansa.stark@edem.es', 'Sansa70@', 'https://ui-avatars.com/api/?name=Sansa%20Stark&size=200'),
('ALU-103', 'Scott', 'Lang', 'scott.lang@edem.es', 'Scott851#', 'https://ui-avatars.com/api/?name=Scott%20Lang&size=200'),
('ALU-104', 'Seamus', 'Finnigan', 'seamus.finnigan@edem.es', 'Seamus_9!', 'https://ui-avatars.com/api/?name=Seamus%20Finnigan&size=200'),
('ALU-105', 'Selina', 'Kyle', 'selina.kyle@edem.es', 'Selina2025*', 'https://ui-avatars.com/api/?name=Selina%20Kyle&size=200'),
('ALU-106', 'Stephen', 'Strange', 'stephen.strange@edem.es', 'Stephen482!', 'https://ui-avatars.com/api/?name=Stephen%20Strange&size=200'),
('ALU-107', 'Steve', 'Rogers', 'steve.rogers@edem.es', 'Steve903!', 'https://ui-avatars.com/api/?name=Steve%20Rogers&size=200'),
('ALU-108', 'Tauriel', 'Greenwood', 'tauriel.greenwood@edem.es', 'Tauriel_30$', 'https://ui-avatars.com/api/?name=Tauriel%20Greenwood&size=200'),
('ALU-109', 'Theoden', 'Rohan', 'theoden.rohan@edem.es', 'Theoden_33!', 'https://ui-avatars.com/api/?name=Theoden%20Rohan&size=200'),
('ALU-110', 'Theon', 'Greyjoy', 'theon.greyjoy@edem.es', 'Theon@4Mstr', 'https://ui-avatars.com/api/?name=Theon%20Greyjoy&size=200'),
('ALU-111', 'Thor', 'Odinson', 'thor.odinson@edem.es', 'Thor*22Mstr', 'https://ui-avatars.com/api/?name=Thor%20Odinson&size=200'),
('ALU-112', 'Tiana', 'Bayou', 'tiana.bayou@edem.es', 'Tiana_58&', 'https://ui-avatars.com/api/?name=Tiana%20Bayou&size=200'),
('ALU-113', 'Tony', 'Stark', 'tony.stark@edem.es', 'TonyUni#', 'https://ui-avatars.com/api/?name=Tony%20Stark&size=200'),
('ALU-114', 'Tormund', 'Giantsbane', 'tormund.giantsbane@edem.es', 'Tormund2025*', 'https://ui-avatars.com/api/?name=Tormund%20Giantsbane&size=200'),
('ALU-115', 'Tyrion', 'Lannister', 'tyrion.lannister@edem.es', 'Tyrion325!', 'https://ui-avatars.com/api/?name=Tyrion%20Lannister&size=200'),
('ALU-116', 'Victor', 'Stone', 'victor.stone@edem.es', 'Victor2025!', 'https://ui-avatars.com/api/?name=Victor%20Stone&size=200'),
('ALU-117', 'Wanda', 'Maximoff', 'wanda.maximoff@edem.es', 'Wanda624#', 'https://ui-avatars.com/api/?name=Wanda%20Maximoff&size=200'),
('ALU-118', 'Woody', 'Pride', 'woody.pride@edem.es', 'Woody_39*', 'https://ui-avatars.com/api/?name=Woody%20Pride&size=200'),
('ALU-119', 'Ygritte', 'Wildling', 'ygritte.wildling@edem.es', 'Ygritte_29$', 'https://ui-avatars.com/api/?name=Ygritte%20Wildling&size=200'),
('ALU-120', 'Yoda', 'Dagobah', 'yoda.dagobah@edem.es', 'Yoda_53@', 'https://ui-avatars.com/api/?name=Yoda%20Dagobah&size=200');


-- fabricate-flush


INSERT INTO "asignaturas" ("id_asignatura", "nombre") VALUES
('ASIG-001', 'Análisis de Riesgos Financieros'),
('ASIG-002', 'Arquitectura de Datos'),
('ASIG-003', 'Big Data Analytics'),
('ASIG-004', 'Blockchain y Criptomonedas'),
('ASIG-005', 'Cloud Computing'),
('ASIG-006', 'Contabilidad Financiera'),
('ASIG-007', 'Data Science para Finanzas'),
('ASIG-008', 'Deep Learning'),
('ASIG-009', 'DevOps y CI/CD'),
('ASIG-010', 'Dirección Estratégica'),
('ASIG-011', 'Economía Digital'),
('ASIG-012', 'Economía de la Empresa'),
('ASIG-013', 'Gestión de Proyectos Tecnológicos'),
('ASIG-014', 'Gestión de Recursos Humanos'),
('ASIG-015', 'Ingeniería de Procesos'),
('ASIG-016', 'Innovación y Emprendimiento'),
('ASIG-017', 'Machine Learning'),
('ASIG-018', 'Marketing Digital'),
('ASIG-019', 'Pagos Digitales'),
('ASIG-020', 'Procesamiento de Datos en Tiempo Real'),
('ASIG-021', 'Procesamiento de Lenguaje Natural'),
('ASIG-022', 'Regulación Financiera Digital'),
('ASIG-023', 'Sistemas de Información Empresarial'),
('ASIG-024', 'Visión por Computador'),
('ASIG-025', 'Ética en Inteligencia Artificial');


-- fabricate-flush



INSERT INTO "grupos" ("id_grupo", "nombre") VALUES
('GRP-001', 'GADE'),
('GRP-002', 'GIGE'),
('GRP-003', 'MDA A'),
('GRP-004', 'MDA B'),
('GRP-005', 'MFT'),
('GRP-006', 'MIA');


-- fabricate-flush


INSERT INTO "personal_edem" ("id_personal", "nombre", "apellido", "correo", "rol", "url_foto", "contrasena") VALUES
('PER-001', 'Andrea', 'Soler', 'andrea.soler@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Andrea%20Soler&size=200', 'Andrea16$2025'),
('PER-002', 'Luis', 'Marín', 'luis.marin@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Luis%20Mar%C3%ADn&size=200', 'LuisMarín#79'),
('PER-003', 'Miguel', 'Herrera', 'miguel.herrera@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Miguel%20Herrera&size=200', 'Miguel.2025%'),
('PER-004', 'Sara', 'Reyes', 'sara.reyes@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Sara%20Reyes&size=200', 'Sara.2026$');


-- fabricate-flush


INSERT INTO "profesores" ("id_profesor", "nombre", "apellido", "correo", "url_foto", "contrasena") VALUES
('PROF-001', 'Alberto', 'Gil', 'alberto.gil@edem.es', 'https://ui-avatars.com/api/?name=Alberto%20Gil&size=200', 'Alberto1#2025'),
('PROF-002', 'Ana', 'Fernández', 'ana.fernandez@edem.es', 'https://ui-avatars.com/api/?name=Ana%20Fern%C3%A1ndez&size=200', 'FernándezAna#2024'),
('PROF-003', 'Andrés', 'Herrero', 'andres.herrero@edem.es', 'https://ui-avatars.com/api/?name=Andr%C3%A9s%20Herrero&size=200', 'AndrésHerrero#82'),
('PROF-004', 'Carlos', 'García', 'carlos.garcia@edem.es', 'https://ui-avatars.com/api/?name=Carlos%20Garc%C3%ADa&size=200', 'García2024*99'),
('PROF-005', 'Carmen', 'Álvarez', 'carmen.alvarez@edem.es', 'https://ui-avatars.com/api/?name=Carmen%20%C3%81lvarez&size=200', 'Carmen39!2025'),
('PROF-006', 'Cristina', 'Ortiz', 'cristina.ortiz@edem.es', 'https://ui-avatars.com/api/?name=Cristina%20Ortiz&size=200', 'Cristina.2025!'),
('PROF-007', 'Daniel', 'Morales', 'daniel.morales@edem.es', 'https://ui-avatars.com/api/?name=Daniel%20Morales&size=200', 'MoralesDaniel%2025'),
('PROF-008', 'Diego', 'Ruiz', 'diego.ruiz@edem.es', 'https://ui-avatars.com/api/?name=Diego%20Ruiz&size=200', 'DiegoRuiz#71'),
('PROF-009', 'Elena', 'Moreno', 'elena.moreno@edem.es', 'https://ui-avatars.com/api/?name=Elena%20Moreno&size=200', 'Elena.2024@'),
('PROF-010', 'Fernando', 'Castro', 'fernando.castro@edem.es', 'https://ui-avatars.com/api/?name=Fernando%20Castro&size=200', 'Fernando.2024*'),
('PROF-011', 'Francisco', 'Romero', 'francisco.romero@edem.es', 'https://ui-avatars.com/api/?name=Francisco%20Romero&size=200', 'Francisco7!2024'),
('PROF-012', 'Isabel', 'Navarro', 'isabel.navarro@edem.es', 'https://ui-avatars.com/api/?name=Isabel%20Navarro&size=200', 'Isabel91#2025'),
('PROF-013', 'Javier', 'Martín', 'javier.martin@edem.es', 'https://ui-avatars.com/api/?name=Javier%20Mart%C3%ADn&size=200', 'Javier.2026&'),
('PROF-014', 'Laura', 'Torres', 'laura.torres@edem.es', 'https://ui-avatars.com/api/?name=Laura%20Torres&size=200', 'TorresLaura%2025'),
('PROF-015', 'Lucía', 'Blanco', 'lucia.blanco@edem.es', 'https://ui-avatars.com/api/?name=Luc%C3%ADa%20Blanco&size=200', 'Blanco2026#0'),
('PROF-016', 'Manuel', 'Ramírez', 'manuel.ramirez@edem.es', 'https://ui-avatars.com/api/?name=Manuel%20Ram%C3%ADrez&size=200', 'Ramírez2024#84'),
('PROF-017', 'Marta', 'Delgado', 'marta.delgado@edem.es', 'https://ui-avatars.com/api/?name=Marta%20Delgado&size=200', 'Marta.2026&'),
('PROF-018', 'María', 'López', 'maria.lopez@edem.es', 'https://ui-avatars.com/api/?name=Mar%C3%ADa%20L%C3%B3pez&size=200', 'LópezMaría&2024'),
('PROF-019', 'Pablo', 'Vega', 'pablo.vega@edem.es', 'https://ui-avatars.com/api/?name=Pablo%20Vega&size=200', 'Pablo38*2026'),
('PROF-020', 'Patricia', 'Serrano', 'patricia.serrano@edem.es', 'https://ui-avatars.com/api/?name=Patricia%20Serrano&size=200', 'SerranoPatricia*2024'),
('PROF-021', 'Pedro', 'Sánchez', 'pedro.sanchez@edem.es', 'https://ui-avatars.com/api/?name=Pedro%20S%C3%A1nchez&size=200', 'Pedro76$2024'),
('PROF-022', 'Raúl', 'Jiménez', 'raul.jimenez@edem.es', 'https://ui-avatars.com/api/?name=Ra%C3%BAl%20Jim%C3%A9nez&size=200', 'RaúlJiménez#19'),
('PROF-023', 'Roberto', 'Díaz', 'roberto.diaz@edem.es', 'https://ui-avatars.com/api/?name=Roberto%20D%C3%ADaz&size=200', 'Roberto57!2024'),
('PROF-024', 'Sofía', 'Molina', 'sofia.molina@edem.es', 'https://ui-avatars.com/api/?name=Sof%C3%ADa%20Molina&size=200', 'Sofía31!2024'),
('PROF-025', 'Teresa', 'Peña', 'teresa.pena@edem.es', 'https://ui-avatars.com/api/?name=Teresa%20Pe%C3%B1a&size=200', 'Teresa77$2024');


-- fabricate-flush



INSERT INTO "rel_alumnos_grupos" ("id_alumno", "id_grupo") VALUES
('ALU-052', 'GRP-003'),
('ALU-054', 'GRP-003'),
('ALU-097', 'GRP-003'),
('ALU-035', 'GRP-003'),
('ALU-069', 'GRP-003'),
('ALU-081', 'GRP-003'),
('ALU-049', 'GRP-003'),
('ALU-043', 'GRP-003'),
('ALU-047', 'GRP-003'),
('ALU-025', 'GRP-003'),
('ALU-028', 'GRP-003'),
('ALU-104', 'GRP-003'),
('ALU-032', 'GRP-003'),
('ALU-086', 'GRP-003'),
('ALU-088', 'GRP-003'),
('ALU-064', 'GRP-003'),
('ALU-085', 'GRP-003'),
('ALU-061', 'GRP-003'),
('ALU-004', 'GRP-003'),
('ALU-065', 'GRP-003'),
('ALU-044', 'GRP-004'),
('ALU-101', 'GRP-004'),
('ALU-006', 'GRP-004'),
('ALU-066', 'GRP-004'),
('ALU-048', 'GRP-004'),
('ALU-016', 'GRP-004'),
('ALU-041', 'GRP-004'),
('ALU-039', 'GRP-004'),
('ALU-038', 'GRP-004'),
('ALU-074', 'GRP-004'),
('ALU-090', 'GRP-004'),
('ALU-009', 'GRP-004'),
('ALU-045', 'GRP-004'),
('ALU-036', 'GRP-004'),
('ALU-015', 'GRP-004'),
('ALU-109', 'GRP-004'),
('ALU-050', 'GRP-004'),
('ALU-098', 'GRP-004'),
('ALU-108', 'GRP-004'),
('ALU-026', 'GRP-004'),
('ALU-068', 'GRP-006'),
('ALU-067', 'GRP-006'),
('ALU-051', 'GRP-006'),
('ALU-003', 'GRP-006'),
('ALU-087', 'GRP-006'),
('ALU-083', 'GRP-006'),
('ALU-120', 'GRP-006'),
('ALU-070', 'GRP-006'),
('ALU-001', 'GRP-006'),
('ALU-096', 'GRP-006'),
('ALU-042', 'GRP-006'),
('ALU-093', 'GRP-006'),
('ALU-034', 'GRP-006'),
('ALU-063', 'GRP-006'),
('ALU-059', 'GRP-006'),
('ALU-024', 'GRP-006'),
('ALU-053', 'GRP-006'),
('ALU-040', 'GRP-006'),
('ALU-062', 'GRP-006'),
('ALU-099', 'GRP-006'),
('ALU-113', 'GRP-005'),
('ALU-107', 'GRP-005'),
('ALU-080', 'GRP-005'),
('ALU-019', 'GRP-005'),
('ALU-111', 'GRP-005'),
('ALU-089', 'GRP-005'),
('ALU-117', 'GRP-005'),
('ALU-103', 'GRP-005'),
('ALU-106', 'GRP-005'),
('ALU-023', 'GRP-005'),
('ALU-020', 'GRP-005'),
('ALU-029', 'GRP-005'),
('ALU-033', 'GRP-005'),
('ALU-013', 'GRP-005'),
('ALU-008', 'GRP-005'),
('ALU-105', 'GRP-005'),
('ALU-012', 'GRP-005'),
('ALU-084', 'GRP-005'),
('ALU-060', 'GRP-005'),
('ALU-116', 'GRP-005'),
('ALU-037', 'GRP-001'),
('ALU-005', 'GRP-001'),
('ALU-094', 'GRP-001'),
('ALU-078', 'GRP-001'),
('ALU-079', 'GRP-001'),
('ALU-073', 'GRP-001'),
('ALU-112', 'GRP-001'),
('ALU-007', 'GRP-001'),
('ALU-056', 'GRP-001'),
('ALU-002', 'GRP-001'),
('ALU-118', 'GRP-001'),
('ALU-022', 'GRP-001'),
('ALU-075', 'GRP-001'),
('ALU-076', 'GRP-001'),
('ALU-095', 'GRP-001'),
('ALU-021', 'GRP-001'),
('ALU-072', 'GRP-001'),
('ALU-091', 'GRP-001'),
('ALU-014', 'GRP-001'),
('ALU-011', 'GRP-001'),
('ALU-057', 'GRP-002'),
('ALU-030', 'GRP-002'),
('ALU-010', 'GRP-002'),
('ALU-102', 'GRP-002'),
('ALU-115', 'GRP-002'),
('ALU-027', 'GRP-002'),
('ALU-055', 'GRP-002'),
('ALU-017', 'GRP-002'),
('ALU-110', 'GRP-002'),
('ALU-018', 'GRP-002'),
('ALU-100', 'GRP-002'),
('ALU-058', 'GRP-002'),
('ALU-077', 'GRP-002'),
('ALU-114', 'GRP-002'),
('ALU-031', 'GRP-002'),
('ALU-071', 'GRP-002'),
('ALU-082', 'GRP-002'),
('ALU-119', 'GRP-002'),
('ALU-046', 'GRP-002'),
('ALU-092', 'GRP-002');


-- fabricate-flush


INSERT INTO "rel_asignaturas_grupos" ("id_asignatura", "id_grupo") VALUES
('ASIG-005', 'GRP-003'),
('ASIG-005', 'GRP-004'),
('ASIG-003', 'GRP-003'),
('ASIG-003', 'GRP-004'),
('ASIG-002', 'GRP-003'),
('ASIG-002', 'GRP-004'),
('ASIG-009', 'GRP-003'),
('ASIG-009', 'GRP-004'),
('ASIG-020', 'GRP-003'),
('ASIG-020', 'GRP-004'),
('ASIG-017', 'GRP-006'),
('ASIG-008', 'GRP-006'),
('ASIG-021', 'GRP-006'),
('ASIG-024', 'GRP-006'),
('ASIG-025', 'GRP-006'),
('ASIG-004', 'GRP-005'),
('ASIG-022', 'GRP-005'),
('ASIG-001', 'GRP-005'),
('ASIG-019', 'GRP-005'),
('ASIG-007', 'GRP-005'),
('ASIG-006', 'GRP-001'),
('ASIG-018', 'GRP-001'),
('ASIG-010', 'GRP-001'),
('ASIG-014', 'GRP-001'),
('ASIG-012', 'GRP-001'),
('ASIG-013', 'GRP-002'),
('ASIG-015', 'GRP-002'),
('ASIG-023', 'GRP-002'),
('ASIG-016', 'GRP-002'),
('ASIG-011', 'GRP-002');


-- fabricate-flush


INSERT INTO "rel_personal_grupos" ("id_personal", "id_grupo") VALUES
('PER-003', 'GRP-003'),
('PER-003', 'GRP-004'),
('PER-003', 'GRP-006'),
('PER-001', 'GRP-005'),
('PER-002', 'GRP-001'),
('PER-004', 'GRP-002');


-- fabricate-flush


INSERT INTO "rel_profesores_asignaturas" ("id_profesor", "id_asignatura") VALUES
('PROF-004', 'ASIG-005'),
('PROF-018', 'ASIG-003'),
('PROF-013', 'ASIG-002'),
('PROF-002', 'ASIG-009'),
('PROF-021', 'ASIG-020'),
('PROF-014', 'ASIG-017'),
('PROF-008', 'ASIG-008'),
('PROF-009', 'ASIG-021'),
('PROF-023', 'ASIG-024'),
('PROF-005', 'ASIG-025'),
('PROF-011', 'ASIG-004'),
('PROF-012', 'ASIG-022'),
('PROF-001', 'ASIG-001'),
('PROF-024', 'ASIG-019'),
('PROF-022', 'ASIG-007'),
('PROF-020', 'ASIG-006'),
('PROF-016', 'ASIG-018'),
('PROF-015', 'ASIG-010'),
('PROF-003', 'ASIG-014'),
('PROF-025', 'ASIG-012'),
('PROF-019', 'ASIG-013'),
('PROF-017', 'ASIG-015'),
('PROF-010', 'ASIG-023'),
('PROF-006', 'ASIG-016'),
('PROF-007', 'ASIG-011');


-- fabricate-flush




INSERT INTO "ubicaciones" ("id_ubicacion", "descripcion", "planta", "aula") VALUES
('UBI-001', 'Aula 101 - Planta 1', 1, '101'),
('UBI-002', 'Aula 102 - Planta 1', 1, '102'),
('UBI-003', 'Aula 103 - Planta 1', 1, '103'),
('UBI-004', 'Aula 201 - Planta 2', 2, '201'),
('UBI-005', 'Aula 202 - Planta 2', 2, '202'),
('UBI-006', 'Aula 203 - Planta 2', 2, '203');


-- fabricate-flush


SET session_replication_role = 'origin';
