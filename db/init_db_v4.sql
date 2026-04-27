-- Seeds de ejemplo para el esquema canónico definido en init_db_v2.sql.

TRUNCATE TABLE "alumnos" CASCADE;
TRUNCATE TABLE "bloques" CASCADE;
TRUNCATE TABLE "sesiones" CASCADE;
TRUNCATE TABLE "asistencia" CASCADE;
TRUNCATE TABLE "configuracion_notificaciones" CASCADE;
TRUNCATE TABLE "correos" CASCADE;
TRUNCATE TABLE "contenidos" CASCADE;
TRUNCATE TABLE "eventos" CASCADE;
TRUNCATE TABLE "franja_tutoria" CASCADE;
TRUNCATE TABLE "grupos" CASCADE;
TRUNCATE TABLE "notificaciones" CASCADE;
TRUNCATE TABLE "personal_edem" CASCADE;
TRUNCATE TABLE "profesores" CASCADE;
TRUNCATE TABLE "rel_alumno_tarea" CASCADE;
TRUNCATE TABLE "rel_alumnos_grupos" CASCADE;
TRUNCATE TABLE "rel_bloques_grupos" CASCADE;
TRUNCATE TABLE "rel_personal_grupos" CASCADE;
TRUNCATE TABLE "rel_profesores_bloques" CASCADE;
TRUNCATE TABLE "reservas" CASCADE;
TRUNCATE TABLE "tareas" CASCADE;
TRUNCATE TABLE "ubicaciones" CASCADE;

INSERT INTO "alumnos" ("id_alumno", "nombre", "apellido1", "apellido2", "correo", "contrasena", "url_foto") VALUES
('ALU-001', 'Ahsoka', 'Tano', NULL, 'ahsoka.tano@edem.es', '$2b$12$3vNfcQYMlcuwuOs5e3lQrOVAFo1x8AJrn7ZWdpyKZwb2J9xY90A4S', 'https://ui-avatars.com/api/?name=Ahsoka%20Tano&size=200'),
('ALU-002', 'Aladdin', 'Ababwa', NULL, 'aladdin.ababwa@edem.es', '$2b$12$n5/3HX643A4Z3rb8d8047OmvFj06Lir2AAVXZHahrVi5xo0E6VM2K', 'https://ui-avatars.com/api/?name=Aladdin%20Ababwa&size=200'),
('ALU-003', 'Anakin', 'Skywalker', NULL, 'anakin.skywalker@edem.es', '$2b$12$m4O87aJeVuvFcAn0TEutyufq.By4thfI9S6o0LEVuyTk9sytEoniG', 'https://ui-avatars.com/api/?name=Anakin%20Skywalker&size=200'),
('ALU-004', 'Angelina', 'Johnson', NULL, 'angelina.johnson@edem.es', '$2b$12$86NMDUywTXNuwJ210pXEbeYf4qaS0MJURoifCzc5jXSUlBla7Ur8C', 'https://ui-avatars.com/api/?name=Angelina%20Johnson&size=200'),
('ALU-005', 'Anna', 'Arendelle', NULL, 'anna.arendelle@edem.es', '$2b$12$j5Xm8gs.a3EhtkFjuwQf/u/U20x.pGlwDz3BAsbhNPTKIM1VCtIHu', 'https://ui-avatars.com/api/?name=Anna%20Arendelle&size=200'),
('ALU-006', 'Aragorn', 'Elessar', NULL, 'aragorn.elessar@edem.es', '$2b$12$hJmZXLTpxS1Gy5oLpmdTQOkQ3YmSQI3gnAENBKTnZlsVNPQlyQSoa', 'https://ui-avatars.com/api/?name=Aragorn%20Elessar&size=200'),
('ALU-007', 'Ariel', 'Triton', NULL, 'ariel.triton@edem.es', '$2b$12$xQu8GfJwNnpLTYRAgC6ouecuF60BDrTc9FjSKlwcAywcdWFkTNu5m', 'https://ui-avatars.com/api/?name=Ariel%20Triton&size=200'),
('ALU-008', 'Arthur', 'Curry', NULL, 'arthur.curry@edem.es', '$2b$12$LJUykJGlDfHmk1IyRCTSxeoOinzx6QW3af26qWHrjHT6uDANpON9G', 'https://ui-avatars.com/api/?name=Arthur%20Curry&size=200'),
('ALU-009', 'Arwen', 'Undomiel', NULL, 'arwen.undomiel@edem.es', '$2b$12$qq4ttMwZ2F4I4w78Ws7aAOGluI5bniy9iiNNzXP2FZ4JG3LLMfiT.', 'https://ui-avatars.com/api/?name=Arwen%20Undomiel&size=200'),
('ALU-010', 'Arya', 'Stark', NULL, 'arya.stark@edem.es', '$2b$12$b6bFR1mYD9.KnJIJjwz2ROZZrsqKEcsC1pmSwAqsMHFeIOBdj17Ey', 'https://ui-avatars.com/api/?name=Arya%20Stark&size=200'),
('ALU-011', 'Aurora', 'Rose', NULL, 'aurora.rose@edem.es', '$2b$12$X/EhFP9lsZtpAfosarbGAepEAdMHL6Z/Qkx0zFzJhAJulyn9WgZVC', 'https://ui-avatars.com/api/?name=Aurora%20Rose&size=200'),
('ALU-012', 'Barbara', 'Gordon', NULL, 'barbara.gordon@edem.es', '$2b$12$b4.XH.jI0lnGMwd9ft0PmuGc/S2chyzmt3Qwwk1s/QIC4oYrf9mT2', 'https://ui-avatars.com/api/?name=Barbara%20Gordon&size=200'),
('ALU-013', 'Barry', 'Allen', NULL, 'barry.allen@edem.es', '$2b$12$JHownF67yLT0hTgGdzSRfuh1uvS2a7OvL0c3CONeScB3p1W81QV3q', 'https://ui-avatars.com/api/?name=Barry%20Allen&size=200'),
('ALU-014', 'Bella', 'Beaumont', NULL, 'bella.beaumont@edem.es', '$2b$12$iCFwK9bBrfIPbMJRRD6HyeALQCvm4Fwmz.XUcS/s5Bo7TOk2xRAnK', 'https://ui-avatars.com/api/?name=Bella%20Beaumont&size=200'),
('ALU-015', 'Bilbo', 'Baggins', NULL, 'bilbo.baggins@edem.es', '$2b$12$o6b6fq4HreKaM17x.FBqaufcWEwjrlzJHjI87djv9G1.oa5uXdXeu', 'https://ui-avatars.com/api/?name=Bilbo%20Baggins&size=200'),
('ALU-016', 'Boromir', 'Denethor', NULL, 'boromir.denethor@edem.es', '$2b$12$mSblaPQXIa/berk/CFwX1e0v0V.DYLIepcSVKvpA1KO4lRLlpctly', 'https://ui-avatars.com/api/?name=Boromir%20Denethor&size=200'),
('ALU-017', 'Bran', 'Stark', NULL, 'bran.stark@edem.es', '$2b$12$A8Q1D/uC9D/Lhgf8DqOAQOH9O0SCNd4L.S.jvEJGfxdRU8.UVcRZm', 'https://ui-avatars.com/api/?name=Bran%20Stark&size=200'),
('ALU-018', 'Brienne', 'Tarth', NULL, 'brienne.tarth@edem.es', '$2b$12$angF/mf4KTBvmIfqukvtfuo2asJPYy8uWQJfemWV9gudCCUUfWM1m', 'https://ui-avatars.com/api/?name=Brienne%20Tarth&size=200'),
('ALU-019', 'Bruce', 'Banner', NULL, 'bruce.banner@edem.es', '$2b$12$qHVoaWe1xLuMOshOGhPxxuBJ45pveDGvnr0kNRsOt45ObrI86b87e', 'https://ui-avatars.com/api/?name=Bruce%20Banner&size=200'),
('ALU-020', 'Bruce', 'Wayne', NULL, 'bruce.wayne@edem.es', '$2b$12$FqCfEzlqpZtYuMs7t7W8E.HJHbQlcXXZGITcnLqtotVGajQHpuCF2', 'https://ui-avatars.com/api/?name=Bruce%20Wayne&size=200'),
('ALU-021', 'Bruno', 'Madrigal', NULL, 'bruno.madrigal@edem.es', '$2b$12$4d8p7xlT.hGz1u3nJrZMZ.3eWJKyj0veGximqgBiqd3YqasMblpY2', 'https://ui-avatars.com/api/?name=Bruno%20Madrigal&size=200'),
('ALU-022', 'Buzz', 'Lightyear', NULL, 'buzz.lightyear@edem.es', '$2b$12$tUH.vxg/De66ObbTMRjNS.WiTEG0KKM6rzxpU0taAsKt9XaVXWCn.', 'https://ui-avatars.com/api/?name=Buzz%20Lightyear&size=200'),
('ALU-023', 'Carol', 'Danvers', NULL, 'carol.danvers@edem.es', '$2b$12$JTpvl.KG5lviq1sHaWKapO/q6vpmTaXSUhSFs.HyhUGRWydQIDUVO', 'https://ui-avatars.com/api/?name=Carol%20Danvers&size=200'),
('ALU-024', 'Cassian', 'Andor', NULL, 'cassian.andor@edem.es', '$2b$12$ejFX/W6/GfXolDsj3JMbaOCtQLcCvdC.JwQF4AUxLCXQWv7tr0LNG', 'https://ui-avatars.com/api/?name=Cassian%20Andor&size=200'),
('ALU-025', 'Cedric', 'Diggory', NULL, 'cedric.diggory@edem.es', '$2b$12$6cowVur9ZADUjne1uLwsFufE3aN.74mqGkh1tVh1cf.eaD6MDcEoS', 'https://ui-avatars.com/api/?name=Cedric%20Diggory&size=200'),
('ALU-026', 'Celeborn', 'Lorien', NULL, 'celeborn.lorien@edem.es', '$2b$12$OOk97Ze.Rudqe9/MMQJ7GeeYMUUpPQilQRC3pAjPGt2y15uy8/age', 'https://ui-avatars.com/api/?name=Celeborn%20Lorien&size=200'),
('ALU-027', 'Cersei', 'Lannister', NULL, 'cersei.lannister@edem.es', '$2b$12$Ntt37wWdgAzCivEs4I7U0uYYEWwW8t3kZatFgdyfQ.sag6PVnFWcK', 'https://ui-avatars.com/api/?name=Cersei%20Lannister&size=200'),
('ALU-028', 'Cho', 'Chang', NULL, 'cho.chang@edem.es', '$2b$12$ybpcO8HrarxONkk6ufhaReNHFMyghegttJjvk.f6v7AHK9xl1nQWq', 'https://ui-avatars.com/api/?name=Cho%20Chang&size=200'),
('ALU-029', 'Clark', 'Kent', NULL, 'clark.kent@edem.es', '$2b$12$CiHrWuUhkB1bmvE8wLebyuGG1UncVfJcVst9gogreVMo5oSbLU2se', 'https://ui-avatars.com/api/?name=Clark%20Kent&size=200'),
('ALU-030', 'Daenerys', 'Targaryen', NULL, 'daenerys.targaryen@edem.es', '$2b$12$mY2BJjE0pgE/iRG5MGJJBe09S6p.0byGIgZTZOc9zYoADU5sE3EES', 'https://ui-avatars.com/api/?name=Daenerys%20Targaryen&size=200'),
('ALU-031', 'Davos', 'Seaworth', NULL, 'davos.seaworth@edem.es', '$2b$12$/YB3Fql5nYrJOmwot6FkQuBkCgnKJyl0tPMLeAUxkbHlkqOcNx//m', 'https://ui-avatars.com/api/?name=Davos%20Seaworth&size=200'),
('ALU-032', 'Dean', 'Thomas', NULL, 'dean.thomas@edem.es', '$2b$12$IIfsQoktT5NT1Hx7dHdxC.QkhN8hHO44mJ5lDITSWyeI6JiZDh3xi', 'https://ui-avatars.com/api/?name=Dean%20Thomas&size=200'),
('ALU-033', 'Diana', 'Prince', NULL, 'diana.prince@edem.es', '$2b$12$oIKc8p4zfhvLjNjqa2Cb7OhyDqbm4a4nqgLQOXFMpvy5wFMI1Dkbq', 'https://ui-avatars.com/api/?name=Diana%20Prince&size=200'),
('ALU-034', 'Din', 'Djarin', NULL, 'din.djarin@edem.es', '$2b$12$F.RnBpmW0C.zvXKrNsBzr.LtWebKS4Pc9MqHPWNLfYcEMK9u2184.', 'https://ui-avatars.com/api/?name=Din%20Djarin&size=200'),
('ALU-035', 'Draco', 'Malfoy', NULL, 'draco.malfoy@edem.es', '$2b$12$V4Tkem9qu/p0JFwuOFP7w.f1lyRHpw6QC2dbCS/k9Qs4lvpT3m5gm', 'https://ui-avatars.com/api/?name=Draco%20Malfoy&size=200'),
('ALU-036', 'Elrond', 'Rivendell', NULL, 'elrond.rivendell@edem.es', '$2b$12$lhrVQ7IJA/mhOZz7rwCjT.cNmXwxx8KRG78JidF5BUieRldYOyyA6', 'https://ui-avatars.com/api/?name=Elrond%20Rivendell&size=200'),
('ALU-037', 'Elsa', 'Arendelle', NULL, 'elsa.arendelle@edem.es', '$2b$12$hrj5MVjY24YMC3voRn0xWeXrzaplTalJvx.cnhxh8e0QfOZJA1rpS', 'https://ui-avatars.com/api/?name=Elsa%20Arendelle&size=200'),
('ALU-038', 'Eomer', 'Rohan', NULL, 'eomer.rohan@edem.es', '$2b$12$hnnLHDplneX3NQNkuKoHLuxpXjjQHnXMlgvZyVEJ/iRbplnhs4QtW', 'https://ui-avatars.com/api/?name=Eomer%20Rohan&size=200'),
('ALU-039', 'Eowyn', 'Rohan', NULL, 'eowyn.rohan@edem.es', '$2b$12$Oq490uGjhk9CepyftrERde3Yni5ekRICOwfvBLrtBiu7vax6pTax6', 'https://ui-avatars.com/api/?name=Eowyn%20Rohan&size=200'),
('ALU-040', 'Ezra', 'Bridger', NULL, 'ezra.bridger@edem.es', '$2b$12$YHfnUR7aImPlPpZNdrbeIe0rs85mDIAvNPjUrmneTM2V0r6nHYHhq', 'https://ui-avatars.com/api/?name=Ezra%20Bridger&size=200'),
('ALU-041', 'Faramir', 'Denethor', NULL, 'faramir.denethor@edem.es', '$2b$12$LXn/nY4PvCh.o4ke.hNlWec5P.TnjX9aT9DnitD5pUdg3SJyPe72e', 'https://ui-avatars.com/api/?name=Faramir%20Denethor&size=200'),
('ALU-042', 'Finn', 'Storm', NULL, 'finn.storm@edem.es', '$2b$12$8yUyD6Whr3lEcnarcLIWBuAa9YLTw3Zy2yXyaZP7XwA29m99DkIWi', 'https://ui-avatars.com/api/?name=Finn%20Storm&size=200'),
('ALU-043', 'Fred', 'Weasley', NULL, 'fred.weasley@edem.es', '$2b$12$Lo95h8vmpgobroFEqTx7xuAUu4.wfUIsAvOgH7dT7Sn84FOltFOQO', 'https://ui-avatars.com/api/?name=Fred%20Weasley&size=200'),
('ALU-044', 'Frodo', 'Baggins', NULL, 'frodo.baggins@edem.es', '$2b$12$49digedWg1EPSUfHcCDy3.2UVFdxDFxA8SiavHS1UuuLh2ykNg2xO', 'https://ui-avatars.com/api/?name=Frodo%20Baggins&size=200'),
('ALU-045', 'Galadriel', 'Lorien', NULL, 'galadriel.lorien@edem.es', '$2b$12$42KNP8G2VwlBEcb02kHIZOR/R4saUv41Uyv85vw72smIYcTgwRM3C', 'https://ui-avatars.com/api/?name=Galadriel%20Lorien&size=200'),
('ALU-046', 'Gendry', 'Baratheon', NULL, 'gendry.baratheon@edem.es', '$2b$12$1gWDC5rxmIAvqtUYDSeV4eZHori/hI6T9RoSQplWfn8rTUUo/6z5q', 'https://ui-avatars.com/api/?name=Gendry%20Baratheon&size=200'),
('ALU-047', 'George', 'Weasley', NULL, 'george.weasley@edem.es', '$2b$12$aDLsnbUehU.UdrPI6AZ1W.4ONTZ.1gjDduh8b.SEFTzm.Lz172K.G', 'https://ui-avatars.com/api/?name=George%20Weasley&size=200'),
('ALU-048', 'Gimli', 'Gloin', NULL, 'gimli.gloin@edem.es', '$2b$12$MnnW0dwJqpFcACb/Co48fef69ljGILuiVm7YcuoMGQzUfRlWxtrPW', 'https://ui-avatars.com/api/?name=Gimli%20Gloin&size=200'),
('ALU-049', 'Ginny', 'Weasley', NULL, 'ginny.weasley@edem.es', '$2b$12$7nGVIflZunNeS5qbNeyRHOlo7lxeoiux2kJn/ZT9sKKjV5Aj/TpBu', 'https://ui-avatars.com/api/?name=Ginny%20Weasley&size=200'),
('ALU-050', 'Haldir', 'Lorien', NULL, 'haldir.lorien@edem.es', '$2b$12$rPzM/FCHEx68WVGKM/OeOOdSyiZxM3Xx8kuHL4F7kp3uF1xVE0Qaq', 'https://ui-avatars.com/api/?name=Haldir%20Lorien&size=200'),
('ALU-051', 'Han', 'Solo', NULL, 'han.solo@edem.es', '$2b$12$cvVJWzgcflqxrX0Eh.d9NuDEp7kuI.K2n1siwbvez3L2aoDoZW8vu', 'https://ui-avatars.com/api/?name=Han%20Solo&size=200'),
('ALU-052', 'Harry', 'Potter', NULL, 'harry.potter@edem.es', '$2b$12$C1sBfRmwaoogY56RQ2EiaOKnnB6iuJ7ezOdoJMAsx3ld757GJtmSq', 'https://ui-avatars.com/api/?name=Harry%20Potter&size=200'),
('ALU-053', 'Hera', 'Syndulla', NULL, 'hera.syndulla@edem.es', '$2b$12$zP/3/N5Lw5/vLgcVMhiOXujBi5HqVYWsfedVXFLUDYA8KjdvIMdmO', 'https://ui-avatars.com/api/?name=Hera%20Syndulla&size=200'),
('ALU-054', 'Hermione', 'Granger', NULL, 'hermione.granger@edem.es', '$2b$12$DbiX206i0pYHjr9sXtZGlu5I80qsvR99wwdM/ljhYj0pN07kXL4MG', 'https://ui-avatars.com/api/?name=Hermione%20Granger&size=200'),
('ALU-055', 'Jaime', 'Lannister', NULL, 'jaime.lannister@edem.es', '$2b$12$zBE1s/V3yzE2dpJVHcyh6O76Nj.pg0Kvv7/oTPS9lMfl7Oq.AR3yq', 'https://ui-avatars.com/api/?name=Jaime%20Lannister&size=200'),
('ALU-056', 'Jasmine', 'Sultan', NULL, 'jasmine.sultan@edem.es', '$2b$12$bweYLfHJd.3/mka4SKFWAueMOlLCCviA5MrWFtgqRa.Zoa7bsPm5W', 'https://ui-avatars.com/api/?name=Jasmine%20Sultan&size=200'),
('ALU-057', 'Jon', 'Snow', NULL, 'jon.snow@edem.es', '$2b$12$ln0Wu3ao7o9s/eLGNww/KujY2QLjsyNdq6ttPj.x4/w9OWuZWGT66', 'https://ui-avatars.com/api/?name=Jon%20Snow&size=200'),
('ALU-058', 'Jorah', 'Mormont', NULL, 'jorah.mormont@edem.es', '$2b$12$Nkw6P1djMkdlMzzz0t8yOu2XwZ01tIv8JTb6fed7JwE/.LysJk8cC', 'https://ui-avatars.com/api/?name=Jorah%20Mormont&size=200'),
('ALU-059', 'Jyn', 'Erso', NULL, 'jyn.erso@edem.es', '$2b$12$jZrJ.8htSI5Li9NcOkHUU.7Iw8uWsDlPq6bAEq5R7M8rYy8vzWo7K', 'https://ui-avatars.com/api/?name=Jyn%20Erso&size=200'),
('ALU-060', 'Kara', 'Zorel', NULL, 'kara.zorel@edem.es', '$2b$12$HalhzhATqPHwscjrhCCBfeCKvBK5ISTJFzgMJ.w0YeUl1z8e36YzW', 'https://ui-avatars.com/api/?name=Kara%20Zorel&size=200'),
('ALU-061', 'Katie', 'Bell', NULL, 'katie.bell@edem.es', '$2b$12$vRF6UjwTkOGnGPDNg6ZFmu.OxAhZH0tbBzS6tOnzQ43p3NTg.CJm.', 'https://ui-avatars.com/api/?name=Katie%20Bell&size=200'),
('ALU-062', 'Kylo', 'Ren', NULL, 'kylo.ren@edem.es', '$2b$12$3jZ7nNHc.Hs1LOkUCJaZCOmfDyIaA.6u7dI9RLBYIRW6TbQfboA3y', 'https://ui-avatars.com/api/?name=Kylo%20Ren&size=200'),
('ALU-063', 'Lando', 'Calrissian', NULL, 'lando.calrissian@edem.es', '$2b$12$ES8ombykVqdESsrTKXWNOOYdcJFGSeR.wLbeioC0Xx8gtVDAhhj56', 'https://ui-avatars.com/api/?name=Lando%20Calrissian&size=200'),
('ALU-064', 'Lavender', 'Brown', NULL, 'lavender.brown@edem.es', '$2b$12$AzkjTsfFuDG8yGgHlx7GA.asAdRM0/NfeKyo/bB5TUNmJJa1BlJIC', 'https://ui-avatars.com/api/?name=Lavender%20Brown&size=200'),
('ALU-065', 'Lee', 'Jordan', NULL, 'lee.jordan@edem.es', '$2b$12$uBiHFza84WRuHT.cCktxH.w7aA.ZxGfnlMCgFXZQDlnOk9cXuiLEu', 'https://ui-avatars.com/api/?name=Lee%20Jordan&size=200'),
('ALU-066', 'Legolas', 'Greenleaf', NULL, 'legolas.greenleaf@edem.es', '$2b$12$3WSaY8Dby8hZfz1bIx6sBeAcFgki.d/wWPOJVo/hbyVX0eVzoznJG', 'https://ui-avatars.com/api/?name=Legolas%20Greenleaf&size=200'),
('ALU-067', 'Leia', 'Organa', NULL, 'leia.organa@edem.es', '$2b$12$Vas19CAeYjPNjndvK6RJ5eMlf5BN3pkw3l3Aw99W67KlofBxekumi', 'https://ui-avatars.com/api/?name=Leia%20Organa&size=200'),
('ALU-068', 'Luke', 'Skywalker', NULL, 'luke.skywalker@edem.es', '$2b$12$ey1PEbj6BGUTr6.xbUYyleGYGjP5w1YyPdLtJG2uhyBT7dpiwq.GK', 'https://ui-avatars.com/api/?name=Luke%20Skywalker&size=200'),
('ALU-069', 'Luna', 'Lovegood', NULL, 'luna.lovegood@edem.es', '$2b$12$eDTYeMyWm5SllRPUxHMXae.e6MZvUM2eY/xzPEjjCyvQ5q.yt6GOq', 'https://ui-avatars.com/api/?name=Luna%20Lovegood&size=200'),
('ALU-070', 'Mace', 'Windu', NULL, 'mace.windu@edem.es', '$2b$12$vEtCfvZXXup.DguG5L9EsuvD1QQd/iDMHBuwEI1.j.Jcn1vAFomSq', 'https://ui-avatars.com/api/?name=Mace%20Windu&size=200'),
('ALU-071', 'Margaery', 'Tyrell', NULL, 'margaery.tyrell@edem.es', '$2b$12$Ls7RITU/lYZCChNcvWnqr./jhM/q/BQwrKRNPWXzDQe.WmI7IjXbO', 'https://ui-avatars.com/api/?name=Margaery%20Tyrell&size=200'),
('ALU-072', 'Maui', 'Motunui', NULL, 'maui.motunui@edem.es', '$2b$12$APx4bTZT5HNRgnwWsg9C9.L7G9ZDKklfslEC6DvfXwul86.zPzNze', 'https://ui-avatars.com/api/?name=Maui%20Motunui&size=200'),
('ALU-073', 'Merida', 'DunBroch', NULL, 'merida.dunbroch@edem.es', '$2b$12$muLZTysAMQX1oqc2rOjmUOqMaoDZQhAQANKNPaz68nU63dgZjpsie', 'https://ui-avatars.com/api/?name=Merida%20DunBroch&size=200'),
('ALU-074', 'Merry', 'Brandybuck', NULL, 'merry.brandybuck@edem.es', '$2b$12$GCsUz/FPwf0AQRSYrgD4ruONJClA/OLjjxtY5DoAWhlNZB3jbtMzu', 'https://ui-avatars.com/api/?name=Merry%20Brandybuck&size=200'),
('ALU-075', 'Miguel', 'Rivera', NULL, 'miguel.rivera@edem.es', '$2b$12$6KeLBo4gaiQvBri8HClBDOm.oOKoPgzTZvRtL4WtzfYg3TEyZwJji', 'https://ui-avatars.com/api/?name=Miguel%20Rivera&size=200'),
('ALU-076', 'Mirabel', 'Madrigal', NULL, 'mirabel.madrigal@edem.es', '$2b$12$XypC47V3Es6qYxqcTTUA1u4AX7QFjzfaQYSWNQzDkoHH560Q.zNbq', 'https://ui-avatars.com/api/?name=Mirabel%20Madrigal&size=200'),
('ALU-077', 'Missandei', 'Naath', NULL, 'missandei.naath@edem.es', '$2b$12$wLhnttblcJtTAAwz7OpQeuG5jBavohHmdV83y9vgkH2d7JdSz52ki', 'https://ui-avatars.com/api/?name=Missandei%20Naath&size=200'),
('ALU-078', 'Moana', 'Motunui', NULL, 'moana.motunui@edem.es', '$2b$12$FGITgG5DBj1Z.lye/cRPWumF2hwPCLVqgtVCgrUdS43MzwMi4Zodm', 'https://ui-avatars.com/api/?name=Moana%20Motunui&size=200'),
('ALU-079', 'Mulan', 'Hua', NULL, 'mulan.hua@edem.es', '$2b$12$RqThe/ue7QqifcZZU45DxefkSSBuKYPBK/C2l.EjCuusdcBLMGJsm', 'https://ui-avatars.com/api/?name=Mulan%20Hua&size=200'),
('ALU-080', 'Natasha', 'Romanoff', NULL, 'natasha.romanoff@edem.es', '$2b$12$Xiecbfux7u2Ykg8Zxeugcevz3zcWXFl1pLUH3NB90Yo4q61ERloki', 'https://ui-avatars.com/api/?name=Natasha%20Romanoff&size=200'),
('ALU-081', 'Neville', 'Longbottom', NULL, 'neville.longbottom@edem.es', '$2b$12$VpwiECT45c/bMhLgYR3OOuj93Q5M.xRyc8xgpCGSE5cTjEHJqJUNu', 'https://ui-avatars.com/api/?name=Neville%20Longbottom&size=200'),
('ALU-082', 'Oberyn', 'Martell', NULL, 'oberyn.martell@edem.es', '$2b$12$AAEFVYoFZ/4osKatAi4TKOQ6HAYFZehdDyAKAl08YkvUEgFRS3pDS', 'https://ui-avatars.com/api/?name=Oberyn%20Martell&size=200'),
('ALU-083', 'Obiwan', 'Kenobi', NULL, 'obiwan.kenobi@edem.es', '$2b$12$BHLGVWEs0bxFBVr9Ykt4legDA2I6do5JPtIqUrGwqqK.B.yucmV76', 'https://ui-avatars.com/api/?name=Obiwan%20Kenobi&size=200'),
('ALU-084', 'Oliver', 'Queen', NULL, 'oliver.queen@edem.es', '$2b$12$VGVvNSbc10zjd9xGMtEUiejrXqJrUYX8Z000XyRajnuCSt7oLBZfi', 'https://ui-avatars.com/api/?name=Oliver%20Queen&size=200'),
('ALU-085', 'Oliver', 'Wood', NULL, 'oliver.wood@edem.es', '$2b$12$GTqFWxWA.lQUYavtsCQKAuH/JB3HgHuBKT.rllABB7FXAKiCTKLiW', 'https://ui-avatars.com/api/?name=Oliver%20Wood&size=200'),
('ALU-086', 'Padma', 'Patil', NULL, 'padma.patil@edem.es', '$2b$12$qXokbHnZCrGAWojwYqNuFech257DZjt5VpalNkXDiIY/2DLHYhgZG', 'https://ui-avatars.com/api/?name=Padma%20Patil&size=200'),
('ALU-087', 'Padme', 'Amidala', NULL, 'padme.amidala@edem.es', '$2b$12$9LgzBIxR0Aw/u7hGIShx0es1eeisdeM96nRi9mzEAFlv5NUIFxV1m', 'https://ui-avatars.com/api/?name=Padme%20Amidala&size=200'),
('ALU-088', 'Parvati', 'Patil', NULL, 'parvati.patil@edem.es', '$2b$12$zrLFAVBASPvLe99XL0Us3OnOIkKf4Eq1AM1fHKMeDzA2WWIo5iwxO', 'https://ui-avatars.com/api/?name=Parvati%20Patil&size=200'),
('ALU-089', 'Peter', 'Parker', NULL, 'peter.parker@edem.es', '$2b$12$cAxxPyVoRBpesfZUdBRqzOCAzBtEnTqoK.Oq/zsh8JF6spaCzLL9W', 'https://ui-avatars.com/api/?name=Peter%20Parker&size=200'),
('ALU-090', 'Pippin', 'Took', NULL, 'pippin.took@edem.es', '$2b$12$a2V/6Nptze3Z12WvEYOzfO15X../vE2LRaVsWvD/L3y8meXoZcseS', 'https://ui-avatars.com/api/?name=Pippin%20Took&size=200'),
('ALU-091', 'Pocahontas', 'Powhatan', NULL, 'pocahontas.powhatan@edem.es', '$2b$12$tuUzet8sBH4WpV0I98mv4OWXiTmi8DHb0raq/7w7sFACJQvQn3Uom', 'https://ui-avatars.com/api/?name=Pocahontas%20Powhatan&size=200'),
('ALU-092', 'Podrick', 'Payne', NULL, 'podrick.payne@edem.es', '$2b$12$sleOQpNqDhHvKb0azXw08eAGeOOZV/Jlv4SNxE257rleWkkahx1Mu', 'https://ui-avatars.com/api/?name=Podrick%20Payne&size=200'),
('ALU-093', 'Poe', 'Dameron', NULL, 'poe.dameron@edem.es', '$2b$12$96JX7SX7kFTk7a0zqhjr5OodFocxzggp6ZkwO4ptZKSyeVami4Dli', 'https://ui-avatars.com/api/?name=Poe%20Dameron&size=200'),
('ALU-094', 'Rapunzel', 'Corona', NULL, 'rapunzel.corona@edem.es', '$2b$12$2yD0bQxiAhcaEoZshXe2w.kJjc/ywFZu0dzdQrjw1KET1aMSYnn0m', 'https://ui-avatars.com/api/?name=Rapunzel%20Corona&size=200'),
('ALU-095', 'Raya', 'Kumandra', NULL, 'raya.kumandra@edem.es', '$2b$12$16oXvH4pdGKDzTLnG/6h5.OUiiYap2D4.wRy3laVvwVpaN6c/9L46', 'https://ui-avatars.com/api/?name=Raya%20Kumandra&size=200'),
('ALU-096', 'Rey', 'Palpatine', NULL, 'rey.palpatine@edem.es', '$2b$12$vcsIlTvDQ62YBQ7y1Rl6VeSZ5hbBplXZIuzRpnpLlVAB6h1nb6GRW', 'https://ui-avatars.com/api/?name=Rey%20Palpatine&size=200'),
('ALU-097', 'Ron', 'Weasley', NULL, 'ron.weasley@edem.es', '$2b$12$oxqa7GP6kJ/Rp1W1hHYOdO5ZIwLM13pIBPTdqJckK9sQJVILavoNe', 'https://ui-avatars.com/api/?name=Ron%20Weasley&size=200'),
('ALU-098', 'Rosie', 'Cotton', NULL, 'rosie.cotton@edem.es', '$2b$12$FVdFAvKGwovtKtRleqqRq.7iiTcEzPaKfyYYyHI/dT7GS9YjsLLu2', 'https://ui-avatars.com/api/?name=Rosie%20Cotton&size=200'),
('ALU-099', 'Sabine', 'Wren', NULL, 'sabine.wren@edem.es', '$2b$12$kipPFt7ChsLkMeJT8jofke1Xg61GTm.oq6C6v4ItQpvWbdy7ABfwy', 'https://ui-avatars.com/api/?name=Sabine%20Wren&size=200'),
('ALU-100', 'Samwell', 'Tarly', NULL, 'samwell.tarly@edem.es', '$2b$12$lP0su5xS4jQtD8X2JgebOe8iWJ/NrIp9HPdbNiBTLNMGYiNbt/X5e', 'https://ui-avatars.com/api/?name=Samwell%20Tarly&size=200'),
('ALU-101', 'Samwise', 'Gamgee', NULL, 'samwise.gamgee@edem.es', '$2b$12$VUhV5oZnPWrusIELGtMJ7ucmGw8Zxnn1vtNKTLNq2UYvQlULouiuO', 'https://ui-avatars.com/api/?name=Samwise%20Gamgee&size=200'),
('ALU-102', 'Sansa', 'Stark', NULL, 'sansa.stark@edem.es', '$2b$12$J6VD62xcUPGPLuRRNJOAoe5qBhIDpZejtb2hBCwEKX2kpGaQT/w9G', 'https://ui-avatars.com/api/?name=Sansa%20Stark&size=200'),
('ALU-103', 'Scott', 'Lang', NULL, 'scott.lang@edem.es', '$2b$12$2JBLCdGe0fU312mb.f1Vx.vda5GuW8V87fzMbmiY4O52Oih8bCQcW', 'https://ui-avatars.com/api/?name=Scott%20Lang&size=200'),
('ALU-104', 'Seamus', 'Finnigan', NULL, 'seamus.finnigan@edem.es', '$2b$12$J7fA8.mTi7Ul//ZMs2QOQO0T.FZ/8RuqJ0JRNMoGWKDxLHbgbNPFS', 'https://ui-avatars.com/api/?name=Seamus%20Finnigan&size=200'),
('ALU-105', 'Selina', 'Kyle', NULL, 'selina.kyle@edem.es', '$2b$12$BacThGEWnxPcO674nAHJ7uDx0qHxOCua8gKUMhy0PSVuOzR28lGRe', 'https://ui-avatars.com/api/?name=Selina%20Kyle&size=200'),
('ALU-106', 'Stephen', 'Strange', NULL, 'stephen.strange@edem.es', '$2b$12$0zFjHzIJbPYIcneGuPNa/ONpGOc.Adr.DmtMlJbtj/Gfma5jdeLX.', 'https://ui-avatars.com/api/?name=Stephen%20Strange&size=200'),
('ALU-107', 'Steve', 'Rogers', NULL, 'steve.rogers@edem.es', '$2b$12$YEqeSIuEJ0uVqfHUPYyW7.Quq0puITziu9VojiKDp8Hc6uyY7lwkW', 'https://ui-avatars.com/api/?name=Steve%20Rogers&size=200'),
('ALU-108', 'Tauriel', 'Greenwood', NULL, 'tauriel.greenwood@edem.es', '$2b$12$N/ivxjaD/N7YtSkKdVlo0.S.BmhYUekDA9vqJPbLAUtj.CXtrE4MS', 'https://ui-avatars.com/api/?name=Tauriel%20Greenwood&size=200'),
('ALU-109', 'Theoden', 'Rohan', NULL, 'theoden.rohan@edem.es', '$2b$12$vVEmNCzORbUAElipsGUHL.UKRm2sQ3nuR7VTSL7k3mXWVprECd4e2', 'https://ui-avatars.com/api/?name=Theoden%20Rohan&size=200'),
('ALU-110', 'Theon', 'Greyjoy', NULL, 'theon.greyjoy@edem.es', '$2b$12$v87Aq8ESqUsptlsfGvNEX.37r16hSs6j83DqMXz4/dli7yzsgRbBK', 'https://ui-avatars.com/api/?name=Theon%20Greyjoy&size=200'),
('ALU-111', 'Thor', 'Odinson', NULL, 'thor.odinson@edem.es', '$2b$12$VDhPlVxmdxPZDRdfByrfgefk0jyGnHeIzK96TJh6zTt.T0qAa4DDO', 'https://ui-avatars.com/api/?name=Thor%20Odinson&size=200'),
('ALU-112', 'Tiana', 'Bayou', NULL, 'tiana.bayou@edem.es', '$2b$12$k7tEEG0uUZW79HdMSxt6oeAHz0qsQrMqW7aur2Fc/RTGr3qkJbp6y', 'https://ui-avatars.com/api/?name=Tiana%20Bayou&size=200'),
('ALU-113', 'Tony', 'Stark', NULL, 'tony.stark@edem.es', '$2b$12$77JAYwAaSwuCl/kuoiW4d.CHdPIhyrx6Xm8/AaC79wn04YI75ZFu.', 'https://ui-avatars.com/api/?name=Tony%20Stark&size=200'),
('ALU-114', 'Tormund', 'Giantsbane', NULL, 'tormund.giantsbane@edem.es', '$2b$12$mzgREpYlNL4KbMm5RBeD3.Ef1LTGi.r9IZJhszCuxFr0DxcaOR4Gm', 'https://ui-avatars.com/api/?name=Tormund%20Giantsbane&size=200'),
('ALU-115', 'Tyrion', 'Lannister', NULL, 'tyrion.lannister@edem.es', '$2b$12$D//ds4Cmm4p9HN0x/Ai2ZOhpxkWRv/HJYzYGtbHXXula9FXaelBTi', 'https://ui-avatars.com/api/?name=Tyrion%20Lannister&size=200'),
('ALU-116', 'Victor', 'Stone', NULL, 'victor.stone@edem.es', '$2b$12$0J35XcXvHxM0kSPngjTwnumbphXmigeJ7ovtRCwNaOUGxpGdDsbJu', 'https://ui-avatars.com/api/?name=Victor%20Stone&size=200'),
('ALU-117', 'Wanda', 'Maximoff', NULL, 'wanda.maximoff@edem.es', '$2b$12$9mzvrlPzMZTgfjO915fZw.w3Vt.862jN0KoyhL4s5aTpbg3Lyt47y', 'https://ui-avatars.com/api/?name=Wanda%20Maximoff&size=200'),
('ALU-118', 'Woody', 'Pride', NULL, 'woody.pride@edem.es', '$2b$12$xub.zCN0SK8sChPunBrtFOZ3u6GNY81XgB4BNf4qT6qEiQFel1f1q', 'https://ui-avatars.com/api/?name=Woody%20Pride&size=200'),
('ALU-119', 'Ygritte', 'Wildling', NULL, 'ygritte.wildling@edem.es', '$2b$12$K80D40mn9reVGqwyOkEIBuu.S0jh5QNkIlJfSIcTNlLUxJPywEaw6', 'https://ui-avatars.com/api/?name=Ygritte%20Wildling&size=200'),
('ALU-120', 'Yoda', 'Dagobah', NULL, 'yoda.dagobah@edem.es', '$2b$12$jSpTfurTC9RncbIPooCMY./sh9/OxzalGbQc9MF5Rt7clddbOj8L6', 'https://ui-avatars.com/api/?name=Yoda%20Dagobah&size=200');


-- fabricate-flush


INSERT INTO "bloques" ("id_bloque", "nombre") VALUES
('BLQ-001', 'Análisis de Riesgos Financieros'),
('BLQ-002', 'Arquitectura de Datos'),
('BLQ-003', 'Big Data Analytics'),
('BLQ-004', 'Blockchain y Criptomonedas'),
('BLQ-005', 'Cloud Computing'),
('BLQ-006', 'Contabilidad Financiera'),
('BLQ-007', 'Data Science para Finanzas'),
('BLQ-008', 'Deep Learning'),
('BLQ-009', 'DevOps y CI/CD'),
('BLQ-010', 'Dirección Estratégica'),
('BLQ-011', 'Economía Digital'),
('BLQ-012', 'Economía de la Empresa'),
('BLQ-013', 'Gestión de Proyectos Tecnológicos'),
('BLQ-014', 'Gestión de Recursos Humanos'),
('BLQ-015', 'Ingeniería de Procesos'),
('BLQ-016', 'Innovación y Emprendimiento'),
('BLQ-017', 'Machine Learning'),
('BLQ-018', 'Marketing Digital'),
('BLQ-019', 'Pagos Digitales'),
('BLQ-020', 'Procesamiento de Datos en Tiempo Real'),
('BLQ-021', 'Procesamiento de Lenguaje Natural'),
('BLQ-022', 'Regulación Financiera Digital'),
('BLQ-023', 'Sistemas de Información Empresarial'),
('BLQ-024', 'Visión por Computador'),
('BLQ-025', 'Ética en Inteligencia Artificial');


-- fabricate-flush

-- Placeholder para sesiones reales de cada bloque.
-- INSERT INTO "sesiones" ("id_sesion", "id_bloque", "nombre", "fecha", "hora_inicio", "hora_fin", "aula") VALUES
-- ('SES-200', 'SES-101', 'ENTORNO CLOUD: AWS Almacenamiento - Sesión 1', '2026-03-01', '09:00', '11:00', 'AULA 101');


INSERT INTO "sesiones" ("id_sesion", "id_bloque", "nombre", "fecha", "hora_inicio", "hora_fin", "aula") VALUES
('SES-0001', 'BLQ-001', 'Clase 1', '2026-04-28', '09:00', '11:00', '201'),
('SES-0002', 'BLQ-001', 'Clase 2', '2026-05-05', '09:00', '11:00', '201'),
('SES-0003', 'BLQ-002', 'Clase 1', '2026-04-22', '09:00', '11:00', '102'),
('SES-0004', 'BLQ-002', 'Clase 2', '2026-04-29', '09:00', '11:00', '102'),
('SES-0005', 'BLQ-003', 'Clase 1', '2026-04-22', '11:00', '13:00', '102'),
('SES-0006', 'BLQ-003', 'Clase 2', '2026-04-29', '11:00', '13:00', '102'),
('SES-0007', 'BLQ-004', 'Clase 1', '2026-04-23', '09:00', '11:00', '203'),
('SES-0008', 'BLQ-004', 'Clase 2', '2026-04-30', '09:00', '11:00', '203'),
('SES-0009', 'BLQ-005', 'Clase 1', '2026-04-23', '11:00', '13:00', '103'),
('SES-0010', 'BLQ-005', 'Clase 2', '2026-04-30', '11:00', '13:00', '103'),
('SES-0011', 'BLQ-006', 'Clase 1', '2026-04-24', '09:00', '11:00', '101'),
('SES-0012', 'BLQ-006', 'Clase 2', '2026-05-08', '09:00', '11:00', '101'),
('SES-0013', 'BLQ-007', 'Clase 1', '2026-04-24', '11:00', '13:00', '201'),
('SES-0014', 'BLQ-007', 'Clase 2', '2026-05-08', '11:00', '13:00', '201'),
('SES-0015', 'BLQ-008', 'Clase 1', '2026-04-21', '09:00', '11:00', '202'),
('SES-0016', 'BLQ-008', 'Clase 2', '2026-04-28', '09:00', '11:00', '202'),
('SES-0017', 'BLQ-009', 'Clase 1', '2026-04-21', '11:00', '13:00', '103'),
('SES-0018', 'BLQ-009', 'Clase 2', '2026-04-28', '11:00', '13:00', '103'),
('SES-0019', 'BLQ-010', 'Clase 1', '2026-04-22', '15:00', '17:00', '101'),
('SES-0020', 'BLQ-010', 'Clase 2', '2026-04-29', '15:00', '17:00', '101'),
('SES-0021', 'BLQ-011', 'Clase 1', '2026-04-23', '15:00', '17:00', '202'),
('SES-0022', 'BLQ-011', 'Clase 2', '2026-04-30', '15:00', '17:00', '202'),
('SES-0023', 'BLQ-012', 'Clase 1', '2026-04-24', '15:00', '17:00', '101'),
('SES-0024', 'BLQ-012', 'Clase 2', '2026-05-08', '15:00', '17:00', '101'),
('SES-0025', 'BLQ-013', 'Clase 1', '2026-04-21', '15:00', '17:00', '203'),
('SES-0026', 'BLQ-013', 'Clase 2', '2026-04-28', '15:00', '17:00', '203'),
('SES-0027', 'BLQ-014', 'Clase 1', '2026-04-22', '09:00', '11:00', '103'),
('SES-0028', 'BLQ-014', 'Clase 2', '2026-04-29', '09:00', '11:00', '103'),
('SES-0029', 'BLQ-015', 'Clase 1', '2026-04-23', '09:00', '11:00', '201'),
('SES-0030', 'BLQ-015', 'Clase 2', '2026-04-30', '09:00', '11:00', '201'),
('SES-0031', 'BLQ-016', 'Clase 1', '2026-04-24', '09:00', '11:00', '102'),
('SES-0032', 'BLQ-016', 'Clase 2', '2026-05-08', '09:00', '11:00', '102'),
('SES-0033', 'BLQ-017', 'Clase 1', '2026-04-21', '09:00', '11:00', '202'),
('SES-0034', 'BLQ-017', 'Clase 2', '2026-04-28', '09:00', '11:00', '202'),
('SES-0035', 'BLQ-018', 'Clase 1', '2026-04-22', '11:00', '13:00', '101'),
('SES-0036', 'BLQ-018', 'Clase 2', '2026-04-29', '11:00', '13:00', '101'),
('SES-0037', 'BLQ-019', 'Clase 1', '2026-04-23', '11:00', '13:00', '203'),
('SES-0038', 'BLQ-019', 'Clase 2', '2026-04-30', '11:00', '13:00', '203'),
('SES-0039', 'BLQ-020', 'Clase 1', '2026-04-24', '11:00', '13:00', '102'),
('SES-0040', 'BLQ-020', 'Clase 2', '2026-05-08', '11:00', '13:00', '102'),
('SES-0041', 'BLQ-021', 'Clase 1', '2026-04-21', '11:00', '13:00', '201'),
('SES-0042', 'BLQ-021', 'Clase 2', '2026-04-28', '11:00', '13:00', '201'),
('SES-0043', 'BLQ-022', 'Clase 1', '2026-04-22', '15:00', '17:00', '203'),
('SES-0044', 'BLQ-022', 'Clase 2', '2026-04-29', '15:00', '17:00', '203'),
('SES-0045', 'BLQ-023', 'Clase 1', '2026-04-23', '15:00', '17:00', '103'),
('SES-0046', 'BLQ-023', 'Clase 2', '2026-04-30', '15:00', '17:00', '103'),
('SES-0047', 'BLQ-024', 'Clase 1', '2026-04-24', '15:00', '17:00', '202'),
('SES-0048', 'BLQ-024', 'Clase 2', '2026-05-08', '15:00', '17:00', '202'),
('SES-0049', 'BLQ-025', 'Clase 1', '2026-04-21', '15:00', '17:00', '101'),
('SES-0050', 'BLQ-025', 'Clase 2', '2026-04-28', '15:00', '17:00', '101');


-- fabricate-flush


INSERT INTO "grupos" ("id_grupo", "nombre") VALUES
('GRP-003', 'MDA A'),
('GRP-006', 'MIA');


-- fabricate-flush


INSERT INTO "personal_edem" ("id_personal", "nombre", "apellido", "correo", "rol", "url_foto", "contrasena") VALUES
('PER-001', 'Andrea', 'Soler', 'andrea.soler@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Andrea%20Soler&size=200', '$2b$12$IriqmhhYrOnw1pkFcAF.aO7IIgyqs/HnJlLxdfC1QRH4USb/4PyGS'),
('PER-002', 'Luis', 'Marín', 'luis.marin@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Luis%20Mar%C3%ADn&size=200', '$2b$12$g3EcZJ4w67SnNiX1sTW0xuEM2nF/E/sHd2VcZIjbD3B282JOK/IXa'),
('PER-003', 'Miguel', 'Herrera', 'miguel.herrera@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Miguel%20Herrera&size=200', '$2b$12$xBgVatarzgScXNE40/UL/O8sHmLXtuNaaEvG2aogv9qlnl86k7AZK'),
('PER-004', 'Sara', 'Reyes', 'sara.reyes@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Sara%20Reyes&size=200', '$2b$12$M/LhhD29/ANvk/Q/leBUAeys09Y5z6XW6ZIZB4Qdu9AyTjxppZ53S');


-- fabricate-flush


INSERT INTO "profesores" ("id_profesor", "nombre", "apellido", "correo", "url_foto", "contrasena") VALUES
('PROF-101', 'Adriana', 'Campos', 'adriana.campos@seed.local', 'https://ui-avatars.com/api/?name=Adriana%20Campos&size=200', 'CHANGE_ME'),
('PROF-102', 'Adrián', 'Colomer', 'adrian.colomer@seed.local', 'https://ui-avatars.com/api/?name=Adri%C3%A1n%20Colomer&size=200', 'CHANGE_ME'),
('PROF-103', 'Bea', 'Ruiz', 'bea.ruiz@seed.local', 'https://ui-avatars.com/api/?name=Bea%20Ruiz&size=200', 'CHANGE_ME'),
('PROF-104', 'Conchita', 'Díaz', 'conchita.diaz@seed.local', 'https://ui-avatars.com/api/?name=Conchita%20D%C3%ADaz&size=200', 'CHANGE_ME'),
('PROF-105', 'Daniel', 'Ruiz', 'daniel.ruiz@seed.local', 'https://ui-avatars.com/api/?name=Daniel%20Ruiz&size=200', 'CHANGE_ME'),
('PROF-106', 'David', 'Pinilla', 'david.pinilla@seed.local', 'https://ui-avatars.com/api/?name=David%20Pinilla&size=200', 'CHANGE_ME'),
('PROF-107', 'Diego', 'Guerrero', 'diego.guerrero@seed.local', 'https://ui-avatars.com/api/?name=Diego%20Guerrero&size=200', 'CHANGE_ME'),
('PROF-108', 'Fabio', 'Castro', 'fabio.castro@seed.local', 'https://ui-avatars.com/api/?name=Fabio%20Castro&size=200', 'CHANGE_ME'),
('PROF-109', 'Franziska', 'Kröger', 'franziska.kroger@seed.local', 'https://ui-avatars.com/api/?name=Franziska%20Kr%C3%B6ger&size=200', 'CHANGE_ME'),
('PROF-110', 'Félix', 'Fuentes', 'felix.fuentes@seed.local', 'https://ui-avatars.com/api/?name=F%C3%A9lix%20Fuentes&size=200', 'CHANGE_ME'),
('PROF-111', 'Hernán', 'Boasso', 'hernan.boasso@seed.local', 'https://ui-avatars.com/api/?name=Hern%C3%A1n%20Boasso&size=200', 'CHANGE_ME'),
('PROF-112', 'Héctor', 'Parra', 'hector.parra@seed.local', 'https://ui-avatars.com/api/?name=H%C3%A9ctor%20Parra&size=200', 'CHANGE_ME'),
('PROF-113', 'Javier', 'Briones', 'javier.briones@seed.local', 'https://ui-avatars.com/api/?name=Javier%20Briones&size=200', 'CHANGE_ME'),
('PROF-114', 'Javier', 'Naranjo', 'javier.naranjo@seed.local', 'https://ui-avatars.com/api/?name=Javier%20Naranjo&size=200', 'CHANGE_ME'),
('PROF-115', 'Josiño', 'Pérez', 'josino.perez@seed.local', 'https://ui-avatars.com/api/?name=Josi%C3%B1o%20P%C3%A9rez&size=200', 'CHANGE_ME'),
('PROF-116', 'José Luis', 'Esteban', 'jose.luis.esteban@seed.local', 'https://ui-avatars.com/api/?name=Jos%C3%A9%20Luis%20Esteban&size=200', 'CHANGE_ME'),
('PROF-117', 'José Luis', 'Gómez', 'jose.luis.gomez@seed.local', 'https://ui-avatars.com/api/?name=Jos%C3%A9%20Luis%20G%C3%B3mez&size=200', 'CHANGE_ME'),
('PROF-118', 'José', 'Sánchez', 'jose.sanchez@seed.local', 'https://ui-avatars.com/api/?name=Jos%C3%A9%20S%C3%A1nchez&size=200', 'CHANGE_ME'),
('PROF-119', 'Juanjo', 'García Milla', 'juanjo.garcia.milla@seed.local', 'https://ui-avatars.com/api/?name=Juanjo%20Garc%C3%ADa%20Milla&size=200', 'CHANGE_ME'),
('PROF-120', 'Lars', 'Lathan', 'lars.lathan@seed.local', 'https://ui-avatars.com/api/?name=Lars%20Lathan&size=200', 'CHANGE_ME'),
('PROF-121', 'Marco', 'Colapietro', 'marco.colapietro@seed.local', 'https://ui-avatars.com/api/?name=Marco%20Colapietro&size=200', 'CHANGE_ME'),
('PROF-122', 'Miguel', 'Moratilla', 'miguel.moratilla@seed.local', 'https://ui-avatars.com/api/?name=Miguel%20Moratilla&size=200', 'CHANGE_ME'),
('PROF-123', 'Nacho', 'Reyes', 'nacho.reyes@seed.local', 'https://ui-avatars.com/api/?name=Nacho%20Reyes&size=200', 'CHANGE_ME'),
('PROF-124', 'Nuria', 'Berzal', 'nuria.berzal@seed.local', 'https://ui-avatars.com/api/?name=Nuria%20Berzal&size=200', 'CHANGE_ME'),
('PROF-125', 'Pedro', 'Nieto', 'pedro.nieto@seed.local', 'https://ui-avatars.com/api/?name=Pedro%20Nieto&size=200', 'CHANGE_ME'),
('PROF-126', 'Rafa', 'López', 'rafa.lopez@seed.local', 'https://ui-avatars.com/api/?name=Rafa%20L%C3%B3pez&size=200', 'CHANGE_ME'),
('PROF-127', 'Rubén', 'Sanchís', 'ruben.sanchis@seed.local', 'https://ui-avatars.com/api/?name=Rub%C3%A9n%20Sanch%C3%ADs&size=200', 'CHANGE_ME'),
('PROF-128', 'Sofía', 'Pinilla', 'sofia.pinilla@seed.local', 'https://ui-avatars.com/api/?name=Sof%C3%ADa%20Pinilla&size=200', 'CHANGE_ME'),
('PROF-129', 'Toni', 'Cantó', 'toni.canto@seed.local', 'https://ui-avatars.com/api/?name=Toni%20Cant%C3%B3&size=200', 'CHANGE_ME'),
('PROF-130', 'Vicent', 'Asensio', 'vicent.asensio@seed.local', 'https://ui-avatars.com/api/?name=Vicent%20Asensio&size=200', 'CHANGE_ME'),
('PROF-131', 'Álvaro', 'Lamas', 'alvaro.lamas@seed.local', 'https://ui-avatars.com/api/?name=%C3%81lvaro%20Lamas&size=200', 'CHANGE_ME'),
('PROF-132', 'Ángel', 'Llosa', 'angel.llosa@seed.local', 'https://ui-avatars.com/api/?name=%C3%81ngel%20Llosa&size=200', 'CHANGE_ME'),
('PROF-133', 'Ángel', 'Rodríguez', 'angel.rodriguez@seed.local', 'https://ui-avatars.com/api/?name=%C3%81ngel%20Rodr%C3%ADguez&size=200', 'CHANGE_ME');


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
('ALU-099', 'GRP-006');


-- fabricate-flush


INSERT INTO "rel_bloques_grupos" ("id_bloque", "id_grupo") VALUES
('BLQ-005', 'GRP-003'),
('BLQ-005', 'GRP-004'),
('BLQ-003', 'GRP-003'),
('BLQ-003', 'GRP-004'),
('BLQ-002', 'GRP-003'),
('BLQ-002', 'GRP-004'),
('BLQ-009', 'GRP-003'),
('BLQ-009', 'GRP-004'),
('BLQ-020', 'GRP-003'),
('BLQ-020', 'GRP-004'),
('BLQ-017', 'GRP-006'),
('BLQ-008', 'GRP-006'),
('BLQ-021', 'GRP-006'),
('BLQ-024', 'GRP-006'),
('BLQ-025', 'GRP-006'),
('BLQ-004', 'GRP-005'),
('BLQ-022', 'GRP-005'),
('BLQ-001', 'GRP-005'),
('BLQ-019', 'GRP-005'),
('BLQ-007', 'GRP-005'),
('BLQ-006', 'GRP-001'),
('BLQ-018', 'GRP-001'),
('BLQ-010', 'GRP-001'),
('BLQ-014', 'GRP-001'),
('BLQ-012', 'GRP-001'),
('BLQ-013', 'GRP-002'),
('BLQ-015', 'GRP-002'),
('BLQ-023', 'GRP-002'),
('BLQ-016', 'GRP-002'),
('BLQ-011', 'GRP-002');


-- fabricate-flush


INSERT INTO "rel_personal_grupos" ("id_personal", "id_grupo") VALUES
('PER-003', 'GRP-003'),
('PER-003', 'GRP-006');


-- fabricate-flush


INSERT INTO "rel_profesores_bloques" ("id_profesor", "id_bloque") VALUES
('PROF-004', 'BLQ-005'),
('PROF-018', 'BLQ-003'),
('PROF-013', 'BLQ-002'),
('PROF-002', 'BLQ-009'),
('PROF-021', 'BLQ-020'),
('PROF-014', 'BLQ-017'),
('PROF-008', 'BLQ-008'),
('PROF-009', 'BLQ-021'),
('PROF-023', 'BLQ-024'),
('PROF-005', 'BLQ-025'),
('PROF-011', 'BLQ-004'),
('PROF-012', 'BLQ-022'),
('PROF-001', 'BLQ-001'),
('PROF-024', 'BLQ-019'),
('PROF-022', 'BLQ-007'),
('PROF-020', 'BLQ-006'),
('PROF-016', 'BLQ-018'),
('PROF-015', 'BLQ-010'),
('PROF-003', 'BLQ-014'),
('PROF-025', 'BLQ-012'),
('PROF-019', 'BLQ-013'),
('PROF-017', 'BLQ-015'),
('PROF-010', 'BLQ-023'),
('PROF-006', 'BLQ-016'),
('PROF-007', 'BLQ-011');


-- fabricate-flush


INSERT INTO "ubicaciones" ("id_ubicacion", "descripcion", "planta", "aula") VALUES
('UBI-101', 'EDEM, PLANTA 1, AULA 101', 1, 'AULA 101'),
('UBI-102', 'EDEM, PLANTA 1, AULA 102', 1, 'AULA 102'),
('UBI-103', 'EDEM, PLANTA 1, AULA 103', 1, 'AULA 103'),
('UBI-104', 'EDEM, PLANTA 1, AULA 107', 1, 'AULA 107'),
('UBI-105', 'EDEM, PLANTA 1, AULA 110', 1, 'AULA 110'),
('UBI-106', 'EDEM, PLANTA 1, AULA 111', 1, 'AULA 111'),
('UBI-107', 'EDEM, PLANTA 2, AULA 202', 2, 'AULA 202'),
('UBI-108', 'EDEM, PLANTA 2, AULA 206', 2, 'AULA 206'),
('UBI-109', 'EDEM, PLANTA 2, AULA 208 (ES)', 2, 'AULA 208 (ES)'),
('UBI-110', 'EDEM, PLANTA 2, AULA 209', 2, 'AULA 209'),
('UBI-111', 'EDEM, PLANTA BAJA, AUDITORIO 01', 0, 'AUDITORIO 01'),
('UBI-112', 'LZD, PLANTA 1, AULA 113', 1, 'AULA 113'),
('UBI-113', 'LZD, PLANTA 1, AULA 115', 1, 'AULA 115'),
('UBI-114', 'Reunión de Microsoft Teams', NULL, NULL);


-- fabricate-flush


SET session_replication_role = 'origin';
