-- Seeds de ejemplo para el esquema canónico definido en init_db_v2.sql.

TRUNCATE TABLE "alumnos" CASCADE;
TRUNCATE TABLE "asignaturas" CASCADE;
TRUNCATE TABLE "asistencia" CASCADE;
TRUNCATE TABLE "configuracion_notificaciones" CASCADE;
TRUNCATE TABLE "correos" CASCADE;
TRUNCATE TABLE "eventos" CASCADE;
TRUNCATE TABLE "franja_tutoria" CASCADE;
TRUNCATE TABLE "grupos" CASCADE;
TRUNCATE TABLE "notificaciones" CASCADE;
TRUNCATE TABLE "personal_edem" CASCADE;
TRUNCATE TABLE "profesores" CASCADE;
TRUNCATE TABLE "rel_alumno_tarea" CASCADE;
TRUNCATE TABLE "rel_alumnos_grupos" CASCADE;
TRUNCATE TABLE "rel_asignaturas_grupos" CASCADE;
TRUNCATE TABLE "rel_personal_grupos" CASCADE;
TRUNCATE TABLE "rel_profesores_asignaturas" CASCADE;
TRUNCATE TABLE "reservas" CASCADE;
TRUNCATE TABLE "sesiones" CASCADE;
TRUNCATE TABLE "tareas" CASCADE;
TRUNCATE TABLE "ubicaciones" CASCADE;

INSERT INTO "alumnos" ("id_alumno", "nombre", "apellido", "correo", "contrasena", "url_foto") VALUES
('ALU-001', 'Ahsoka', 'Tano', 'ahsoka.tano@edem.es', '$2b$12$3vNfcQYMlcuwuOs5e3lQrOVAFo1x8AJrn7ZWdpyKZwb2J9xY90A4S', 'https://ui-avatars.com/api/?name=Ahsoka%20Tano&size=200'),
('ALU-002', 'Aladdin', 'Ababwa', 'aladdin.ababwa@edem.es', '$2b$12$n5/3HX643A4Z3rb8d8047OmvFj06Lir2AAVXZHahrVi5xo0E6VM2K', 'https://ui-avatars.com/api/?name=Aladdin%20Ababwa&size=200'),
('ALU-003', 'Anakin', 'Skywalker', 'anakin.skywalker@edem.es', '$2b$12$m4O87aJeVuvFcAn0TEutyufq.By4thfI9S6o0LEVuyTk9sytEoniG', 'https://ui-avatars.com/api/?name=Anakin%20Skywalker&size=200'),
('ALU-004', 'Angelina', 'Johnson', 'angelina.johnson@edem.es', '$2b$12$86NMDUywTXNuwJ210pXEbeYf4qaS0MJURoifCzc5jXSUlBla7Ur8C', 'https://ui-avatars.com/api/?name=Angelina%20Johnson&size=200'),
('ALU-005', 'Anna', 'Arendelle', 'anna.arendelle@edem.es', '$2b$12$j5Xm8gs.a3EhtkFjuwQf/u/U20x.pGlwDz3BAsbhNPTKIM1VCtIHu', 'https://ui-avatars.com/api/?name=Anna%20Arendelle&size=200'),
('ALU-006', 'Aragorn', 'Elessar', 'aragorn.elessar@edem.es', '$2b$12$hJmZXLTpxS1Gy5oLpmdTQOkQ3YmSQI3gnAENBKTnZlsVNPQlyQSoa', 'https://ui-avatars.com/api/?name=Aragorn%20Elessar&size=200'),
('ALU-007', 'Ariel', 'Triton', 'ariel.triton@edem.es', '$2b$12$xQu8GfJwNnpLTYRAgC6ouecuF60BDrTc9FjSKlwcAywcdWFkTNu5m', 'https://ui-avatars.com/api/?name=Ariel%20Triton&size=200'),
('ALU-008', 'Arthur', 'Curry', 'arthur.curry@edem.es', '$2b$12$LJUykJGlDfHmk1IyRCTSxeoOinzx6QW3af26qWHrjHT6uDANpON9G', 'https://ui-avatars.com/api/?name=Arthur%20Curry&size=200'),
('ALU-009', 'Arwen', 'Undomiel', 'arwen.undomiel@edem.es', '$2b$12$qq4ttMwZ2F4I4w78Ws7aAOGluI5bniy9iiNNzXP2FZ4JG3LLMfiT.', 'https://ui-avatars.com/api/?name=Arwen%20Undomiel&size=200'),
('ALU-010', 'Arya', 'Stark', 'arya.stark@edem.es', '$2b$12$b6bFR1mYD9.KnJIJjwz2ROZZrsqKEcsC1pmSwAqsMHFeIOBdj17Ey', 'https://ui-avatars.com/api/?name=Arya%20Stark&size=200'),
('ALU-011', 'Aurora', 'Rose', 'aurora.rose@edem.es', '$2b$12$X/EhFP9lsZtpAfosarbGAepEAdMHL6Z/Qkx0zFzJhAJulyn9WgZVC', 'https://ui-avatars.com/api/?name=Aurora%20Rose&size=200'),
('ALU-012', 'Barbara', 'Gordon', 'barbara.gordon@edem.es', '$2b$12$b4.XH.jI0lnGMwd9ft0PmuGc/S2chyzmt3Qwwk1s/QIC4oYrf9mT2', 'https://ui-avatars.com/api/?name=Barbara%20Gordon&size=200'),
('ALU-013', 'Barry', 'Allen', 'barry.allen@edem.es', '$2b$12$JHownF67yLT0hTgGdzSRfuh1uvS2a7OvL0c3CONeScB3p1W81QV3q', 'https://ui-avatars.com/api/?name=Barry%20Allen&size=200'),
('ALU-014', 'Bella', 'Beaumont', 'bella.beaumont@edem.es', '$2b$12$iCFwK9bBrfIPbMJRRD6HyeALQCvm4Fwmz.XUcS/s5Bo7TOk2xRAnK', 'https://ui-avatars.com/api/?name=Bella%20Beaumont&size=200'),
('ALU-015', 'Bilbo', 'Baggins', 'bilbo.baggins@edem.es', '$2b$12$o6b6fq4HreKaM17x.FBqaufcWEwjrlzJHjI87djv9G1.oa5uXdXeu', 'https://ui-avatars.com/api/?name=Bilbo%20Baggins&size=200'),
('ALU-016', 'Boromir', 'Denethor', 'boromir.denethor@edem.es', '$2b$12$mSblaPQXIa/berk/CFwX1e0v0V.DYLIepcSVKvpA1KO4lRLlpctly', 'https://ui-avatars.com/api/?name=Boromir%20Denethor&size=200'),
('ALU-017', 'Bran', 'Stark', 'bran.stark@edem.es', '$2b$12$A8Q1D/uC9D/Lhgf8DqOAQOH9O0SCNd4L.S.jvEJGfxdRU8.UVcRZm', 'https://ui-avatars.com/api/?name=Bran%20Stark&size=200'),
('ALU-018', 'Brienne', 'Tarth', 'brienne.tarth@edem.es', '$2b$12$angF/mf4KTBvmIfqukvtfuo2asJPYy8uWQJfemWV9gudCCUUfWM1m', 'https://ui-avatars.com/api/?name=Brienne%20Tarth&size=200'),
('ALU-019', 'Bruce', 'Banner', 'bruce.banner@edem.es', '$2b$12$qHVoaWe1xLuMOshOGhPxxuBJ45pveDGvnr0kNRsOt45ObrI86b87e', 'https://ui-avatars.com/api/?name=Bruce%20Banner&size=200'),
('ALU-020', 'Bruce', 'Wayne', 'bruce.wayne@edem.es', '$2b$12$FqCfEzlqpZtYuMs7t7W8E.HJHbQlcXXZGITcnLqtotVGajQHpuCF2', 'https://ui-avatars.com/api/?name=Bruce%20Wayne&size=200'),
('ALU-021', 'Bruno', 'Madrigal', 'bruno.madrigal@edem.es', '$2b$12$4d8p7xlT.hGz1u3nJrZMZ.3eWJKyj0veGximqgBiqd3YqasMblpY2', 'https://ui-avatars.com/api/?name=Bruno%20Madrigal&size=200'),
('ALU-022', 'Buzz', 'Lightyear', 'buzz.lightyear@edem.es', '$2b$12$tUH.vxg/De66ObbTMRjNS.WiTEG0KKM6rzxpU0taAsKt9XaVXWCn.', 'https://ui-avatars.com/api/?name=Buzz%20Lightyear&size=200'),
('ALU-023', 'Carol', 'Danvers', 'carol.danvers@edem.es', '$2b$12$JTpvl.KG5lviq1sHaWKapO/q6vpmTaXSUhSFs.HyhUGRWydQIDUVO', 'https://ui-avatars.com/api/?name=Carol%20Danvers&size=200'),
('ALU-024', 'Cassian', 'Andor', 'cassian.andor@edem.es', '$2b$12$ejFX/W6/GfXolDsj3JMbaOCtQLcCvdC.JwQF4AUxLCXQWv7tr0LNG', 'https://ui-avatars.com/api/?name=Cassian%20Andor&size=200'),
('ALU-025', 'Cedric', 'Diggory', 'cedric.diggory@edem.es', '$2b$12$6cowVur9ZADUjne1uLwsFufE3aN.74mqGkh1tVh1cf.eaD6MDcEoS', 'https://ui-avatars.com/api/?name=Cedric%20Diggory&size=200'),
('ALU-026', 'Celeborn', 'Lorien', 'celeborn.lorien@edem.es', '$2b$12$OOk97Ze.Rudqe9/MMQJ7GeeYMUUpPQilQRC3pAjPGt2y15uy8/age', 'https://ui-avatars.com/api/?name=Celeborn%20Lorien&size=200'),
('ALU-027', 'Cersei', 'Lannister', 'cersei.lannister@edem.es', '$2b$12$Ntt37wWdgAzCivEs4I7U0uYYEWwW8t3kZatFgdyfQ.sag6PVnFWcK', 'https://ui-avatars.com/api/?name=Cersei%20Lannister&size=200'),
('ALU-028', 'Cho', 'Chang', 'cho.chang@edem.es', '$2b$12$ybpcO8HrarxONkk6ufhaReNHFMyghegttJjvk.f6v7AHK9xl1nQWq', 'https://ui-avatars.com/api/?name=Cho%20Chang&size=200'),
('ALU-029', 'Clark', 'Kent', 'clark.kent@edem.es', '$2b$12$CiHrWuUhkB1bmvE8wLebyuGG1UncVfJcVst9gogreVMo5oSbLU2se', 'https://ui-avatars.com/api/?name=Clark%20Kent&size=200'),
('ALU-030', 'Daenerys', 'Targaryen', 'daenerys.targaryen@edem.es', '$2b$12$mY2BJjE0pgE/iRG5MGJJBe09S6p.0byGIgZTZOc9zYoADU5sE3EES', 'https://ui-avatars.com/api/?name=Daenerys%20Targaryen&size=200'),
('ALU-031', 'Davos', 'Seaworth', 'davos.seaworth@edem.es', '$2b$12$/YB3Fql5nYrJOmwot6FkQuBkCgnKJyl0tPMLeAUxkbHlkqOcNx//m', 'https://ui-avatars.com/api/?name=Davos%20Seaworth&size=200'),
('ALU-032', 'Dean', 'Thomas', 'dean.thomas@edem.es', '$2b$12$IIfsQoktT5NT1Hx7dHdxC.QkhN8hHO44mJ5lDITSWyeI6JiZDh3xi', 'https://ui-avatars.com/api/?name=Dean%20Thomas&size=200'),
('ALU-033', 'Diana', 'Prince', 'diana.prince@edem.es', '$2b$12$oIKc8p4zfhvLjNjqa2Cb7OhyDqbm4a4nqgLQOXFMpvy5wFMI1Dkbq', 'https://ui-avatars.com/api/?name=Diana%20Prince&size=200'),
('ALU-034', 'Din', 'Djarin', 'din.djarin@edem.es', '$2b$12$F.RnBpmW0C.zvXKrNsBzr.LtWebKS4Pc9MqHPWNLfYcEMK9u2184.', 'https://ui-avatars.com/api/?name=Din%20Djarin&size=200'),
('ALU-035', 'Draco', 'Malfoy', 'draco.malfoy@edem.es', '$2b$12$V4Tkem9qu/p0JFwuOFP7w.f1lyRHpw6QC2dbCS/k9Qs4lvpT3m5gm', 'https://ui-avatars.com/api/?name=Draco%20Malfoy&size=200'),
('ALU-036', 'Elrond', 'Rivendell', 'elrond.rivendell@edem.es', '$2b$12$lhrVQ7IJA/mhOZz7rwCjT.cNmXwxx8KRG78JidF5BUieRldYOyyA6', 'https://ui-avatars.com/api/?name=Elrond%20Rivendell&size=200'),
('ALU-037', 'Elsa', 'Arendelle', 'elsa.arendelle@edem.es', '$2b$12$hrj5MVjY24YMC3voRn0xWeXrzaplTalJvx.cnhxh8e0QfOZJA1rpS', 'https://ui-avatars.com/api/?name=Elsa%20Arendelle&size=200'),
('ALU-038', 'Eomer', 'Rohan', 'eomer.rohan@edem.es', '$2b$12$hnnLHDplneX3NQNkuKoHLuxpXjjQHnXMlgvZyVEJ/iRbplnhs4QtW', 'https://ui-avatars.com/api/?name=Eomer%20Rohan&size=200'),
('ALU-039', 'Eowyn', 'Rohan', 'eowyn.rohan@edem.es', '$2b$12$Oq490uGjhk9CepyftrERde3Yni5ekRICOwfvBLrtBiu7vax6pTax6', 'https://ui-avatars.com/api/?name=Eowyn%20Rohan&size=200'),
('ALU-040', 'Ezra', 'Bridger', 'ezra.bridger@edem.es', '$2b$12$YHfnUR7aImPlPpZNdrbeIe0rs85mDIAvNPjUrmneTM2V0r6nHYHhq', 'https://ui-avatars.com/api/?name=Ezra%20Bridger&size=200'),
('ALU-041', 'Faramir', 'Denethor', 'faramir.denethor@edem.es', '$2b$12$LXn/nY4PvCh.o4ke.hNlWec5P.TnjX9aT9DnitD5pUdg3SJyPe72e', 'https://ui-avatars.com/api/?name=Faramir%20Denethor&size=200'),
('ALU-042', 'Finn', 'Storm', 'finn.storm@edem.es', '$2b$12$8yUyD6Whr3lEcnarcLIWBuAa9YLTw3Zy2yXyaZP7XwA29m99DkIWi', 'https://ui-avatars.com/api/?name=Finn%20Storm&size=200'),
('ALU-043', 'Fred', 'Weasley', 'fred.weasley@edem.es', '$2b$12$Lo95h8vmpgobroFEqTx7xuAUu4.wfUIsAvOgH7dT7Sn84FOltFOQO', 'https://ui-avatars.com/api/?name=Fred%20Weasley&size=200'),
('ALU-044', 'Frodo', 'Baggins', 'frodo.baggins@edem.es', '$2b$12$49digedWg1EPSUfHcCDy3.2UVFdxDFxA8SiavHS1UuuLh2ykNg2xO', 'https://ui-avatars.com/api/?name=Frodo%20Baggins&size=200'),
('ALU-045', 'Galadriel', 'Lorien', 'galadriel.lorien@edem.es', '$2b$12$42KNP8G2VwlBEcb02kHIZOR/R4saUv41Uyv85vw72smIYcTgwRM3C', 'https://ui-avatars.com/api/?name=Galadriel%20Lorien&size=200'),
('ALU-046', 'Gendry', 'Baratheon', 'gendry.baratheon@edem.es', '$2b$12$1gWDC5rxmIAvqtUYDSeV4eZHori/hI6T9RoSQplWfn8rTUUo/6z5q', 'https://ui-avatars.com/api/?name=Gendry%20Baratheon&size=200'),
('ALU-047', 'George', 'Weasley', 'george.weasley@edem.es', '$2b$12$aDLsnbUehU.UdrPI6AZ1W.4ONTZ.1gjDduh8b.SEFTzm.Lz172K.G', 'https://ui-avatars.com/api/?name=George%20Weasley&size=200'),
('ALU-048', 'Gimli', 'Gloin', 'gimli.gloin@edem.es', '$2b$12$MnnW0dwJqpFcACb/Co48fef69ljGILuiVm7YcuoMGQzUfRlWxtrPW', 'https://ui-avatars.com/api/?name=Gimli%20Gloin&size=200'),
('ALU-049', 'Ginny', 'Weasley', 'ginny.weasley@edem.es', '$2b$12$7nGVIflZunNeS5qbNeyRHOlo7lxeoiux2kJn/ZT9sKKjV5Aj/TpBu', 'https://ui-avatars.com/api/?name=Ginny%20Weasley&size=200'),
('ALU-050', 'Haldir', 'Lorien', 'haldir.lorien@edem.es', '$2b$12$rPzM/FCHEx68WVGKM/OeOOdSyiZxM3Xx8kuHL4F7kp3uF1xVE0Qaq', 'https://ui-avatars.com/api/?name=Haldir%20Lorien&size=200'),
('ALU-051', 'Han', 'Solo', 'han.solo@edem.es', '$2b$12$cvVJWzgcflqxrX0Eh.d9NuDEp7kuI.K2n1siwbvez3L2aoDoZW8vu', 'https://ui-avatars.com/api/?name=Han%20Solo&size=200'),
('ALU-052', 'Harry', 'Potter', 'harry.potter@edem.es', '$2b$12$C1sBfRmwaoogY56RQ2EiaOKnnB6iuJ7ezOdoJMAsx3ld757GJtmSq', 'https://ui-avatars.com/api/?name=Harry%20Potter&size=200'),
('ALU-053', 'Hera', 'Syndulla', 'hera.syndulla@edem.es', '$2b$12$zP/3/N5Lw5/vLgcVMhiOXujBi5HqVYWsfedVXFLUDYA8KjdvIMdmO', 'https://ui-avatars.com/api/?name=Hera%20Syndulla&size=200'),
('ALU-054', 'Hermione', 'Granger', 'hermione.granger@edem.es', '$2b$12$DbiX206i0pYHjr9sXtZGlu5I80qsvR99wwdM/ljhYj0pN07kXL4MG', 'https://ui-avatars.com/api/?name=Hermione%20Granger&size=200'),
('ALU-055', 'Jaime', 'Lannister', 'jaime.lannister@edem.es', '$2b$12$zBE1s/V3yzE2dpJVHcyh6O76Nj.pg0Kvv7/oTPS9lMfl7Oq.AR3yq', 'https://ui-avatars.com/api/?name=Jaime%20Lannister&size=200'),
('ALU-056', 'Jasmine', 'Sultan', 'jasmine.sultan@edem.es', '$2b$12$bweYLfHJd.3/mka4SKFWAueMOlLCCviA5MrWFtgqRa.Zoa7bsPm5W', 'https://ui-avatars.com/api/?name=Jasmine%20Sultan&size=200'),
('ALU-057', 'Jon', 'Snow', 'jon.snow@edem.es', '$2b$12$ln0Wu3ao7o9s/eLGNww/KujY2QLjsyNdq6ttPj.x4/w9OWuZWGT66', 'https://ui-avatars.com/api/?name=Jon%20Snow&size=200'),
('ALU-058', 'Jorah', 'Mormont', 'jorah.mormont@edem.es', '$2b$12$Nkw6P1djMkdlMzzz0t8yOu2XwZ01tIv8JTb6fed7JwE/.LysJk8cC', 'https://ui-avatars.com/api/?name=Jorah%20Mormont&size=200'),
('ALU-059', 'Jyn', 'Erso', 'jyn.erso@edem.es', '$2b$12$jZrJ.8htSI5Li9NcOkHUU.7Iw8uWsDlPq6bAEq5R7M8rYy8vzWo7K', 'https://ui-avatars.com/api/?name=Jyn%20Erso&size=200'),
('ALU-060', 'Kara', 'Zorel', 'kara.zorel@edem.es', '$2b$12$HalhzhATqPHwscjrhCCBfeCKvBK5ISTJFzgMJ.w0YeUl1z8e36YzW', 'https://ui-avatars.com/api/?name=Kara%20Zorel&size=200'),
('ALU-061', 'Katie', 'Bell', 'katie.bell@edem.es', '$2b$12$vRF6UjwTkOGnGPDNg6ZFmu.OxAhZH0tbBzS6tOnzQ43p3NTg.CJm.', 'https://ui-avatars.com/api/?name=Katie%20Bell&size=200'),
('ALU-062', 'Kylo', 'Ren', 'kylo.ren@edem.es', '$2b$12$3jZ7nNHc.Hs1LOkUCJaZCOmfDyIaA.6u7dI9RLBYIRW6TbQfboA3y', 'https://ui-avatars.com/api/?name=Kylo%20Ren&size=200'),
('ALU-063', 'Lando', 'Calrissian', 'lando.calrissian@edem.es', '$2b$12$ES8ombykVqdESsrTKXWNOOYdcJFGSeR.wLbeioC0Xx8gtVDAhhj56', 'https://ui-avatars.com/api/?name=Lando%20Calrissian&size=200'),
('ALU-064', 'Lavender', 'Brown', 'lavender.brown@edem.es', '$2b$12$AzkjTsfFuDG8yGgHlx7GA.asAdRM0/NfeKyo/bB5TUNmJJa1BlJIC', 'https://ui-avatars.com/api/?name=Lavender%20Brown&size=200'),
('ALU-065', 'Lee', 'Jordan', 'lee.jordan@edem.es', '$2b$12$uBiHFza84WRuHT.cCktxH.w7aA.ZxGfnlMCgFXZQDlnOk9cXuiLEu', 'https://ui-avatars.com/api/?name=Lee%20Jordan&size=200'),
('ALU-066', 'Legolas', 'Greenleaf', 'legolas.greenleaf@edem.es', '$2b$12$3WSaY8Dby8hZfz1bIx6sBeAcFgki.d/wWPOJVo/hbyVX0eVzoznJG', 'https://ui-avatars.com/api/?name=Legolas%20Greenleaf&size=200'),
('ALU-067', 'Leia', 'Organa', 'leia.organa@edem.es', '$2b$12$Vas19CAeYjPNjndvK6RJ5eMlf5BN3pkw3l3Aw99W67KlofBxekumi', 'https://ui-avatars.com/api/?name=Leia%20Organa&size=200'),
('ALU-068', 'Luke', 'Skywalker', 'luke.skywalker@edem.es', '$2b$12$ey1PEbj6BGUTr6.xbUYyleGYGjP5w1YyPdLtJG2uhyBT7dpiwq.GK', 'https://ui-avatars.com/api/?name=Luke%20Skywalker&size=200'),
('ALU-069', 'Luna', 'Lovegood', 'luna.lovegood@edem.es', '$2b$12$eDTYeMyWm5SllRPUxHMXae.e6MZvUM2eY/xzPEjjCyvQ5q.yt6GOq', 'https://ui-avatars.com/api/?name=Luna%20Lovegood&size=200'),
('ALU-070', 'Mace', 'Windu', 'mace.windu@edem.es', '$2b$12$vEtCfvZXXup.DguG5L9EsuvD1QQd/iDMHBuwEI1.j.Jcn1vAFomSq', 'https://ui-avatars.com/api/?name=Mace%20Windu&size=200'),
('ALU-071', 'Margaery', 'Tyrell', 'margaery.tyrell@edem.es', '$2b$12$Ls7RITU/lYZCChNcvWnqr./jhM/q/BQwrKRNPWXzDQe.WmI7IjXbO', 'https://ui-avatars.com/api/?name=Margaery%20Tyrell&size=200'),
('ALU-072', 'Maui', 'Motunui', 'maui.motunui@edem.es', '$2b$12$APx4bTZT5HNRgnwWsg9C9.L7G9ZDKklfslEC6DvfXwul86.zPzNze', 'https://ui-avatars.com/api/?name=Maui%20Motunui&size=200'),
('ALU-073', 'Merida', 'DunBroch', 'merida.dunbroch@edem.es', '$2b$12$muLZTysAMQX1oqc2rOjmUOqMaoDZQhAQANKNPaz68nU63dgZjpsie', 'https://ui-avatars.com/api/?name=Merida%20DunBroch&size=200'),
('ALU-074', 'Merry', 'Brandybuck', 'merry.brandybuck@edem.es', '$2b$12$GCsUz/FPwf0AQRSYrgD4ruONJClA/OLjjxtY5DoAWhlNZB3jbtMzu', 'https://ui-avatars.com/api/?name=Merry%20Brandybuck&size=200'),
('ALU-075', 'Miguel', 'Rivera', 'miguel.rivera@edem.es', '$2b$12$6KeLBo4gaiQvBri8HClBDOm.oOKoPgzTZvRtL4WtzfYg3TEyZwJji', 'https://ui-avatars.com/api/?name=Miguel%20Rivera&size=200'),
('ALU-076', 'Mirabel', 'Madrigal', 'mirabel.madrigal@edem.es', '$2b$12$XypC47V3Es6qYxqcTTUA1u4AX7QFjzfaQYSWNQzDkoHH560Q.zNbq', 'https://ui-avatars.com/api/?name=Mirabel%20Madrigal&size=200'),
('ALU-077', 'Missandei', 'Naath', 'missandei.naath@edem.es', '$2b$12$wLhnttblcJtTAAwz7OpQeuG5jBavohHmdV83y9vgkH2d7JdSz52ki', 'https://ui-avatars.com/api/?name=Missandei%20Naath&size=200'),
('ALU-078', 'Moana', 'Motunui', 'moana.motunui@edem.es', '$2b$12$FGITgG5DBj1Z.lye/cRPWumF2hwPCLVqgtVCgrUdS43MzwMi4Zodm', 'https://ui-avatars.com/api/?name=Moana%20Motunui&size=200'),
('ALU-079', 'Mulan', 'Hua', 'mulan.hua@edem.es', '$2b$12$RqThe/ue7QqifcZZU45DxefkSSBuKYPBK/C2l.EjCuusdcBLMGJsm', 'https://ui-avatars.com/api/?name=Mulan%20Hua&size=200'),
('ALU-080', 'Natasha', 'Romanoff', 'natasha.romanoff@edem.es', '$2b$12$Xiecbfux7u2Ykg8Zxeugcevz3zcWXFl1pLUH3NB90Yo4q61ERloki', 'https://ui-avatars.com/api/?name=Natasha%20Romanoff&size=200'),
('ALU-081', 'Neville', 'Longbottom', 'neville.longbottom@edem.es', '$2b$12$VpwiECT45c/bMhLgYR3OOuj93Q5M.xRyc8xgpCGSE5cTjEHJqJUNu', 'https://ui-avatars.com/api/?name=Neville%20Longbottom&size=200'),
('ALU-082', 'Oberyn', 'Martell', 'oberyn.martell@edem.es', '$2b$12$AAEFVYoFZ/4osKatAi4TKOQ6HAYFZehdDyAKAl08YkvUEgFRS3pDS', 'https://ui-avatars.com/api/?name=Oberyn%20Martell&size=200'),
('ALU-083', 'Obiwan', 'Kenobi', 'obiwan.kenobi@edem.es', '$2b$12$BHLGVWEs0bxFBVr9Ykt4legDA2I6do5JPtIqUrGwqqK.B.yucmV76', 'https://ui-avatars.com/api/?name=Obiwan%20Kenobi&size=200'),
('ALU-084', 'Oliver', 'Queen', 'oliver.queen@edem.es', '$2b$12$VGVvNSbc10zjd9xGMtEUiejrXqJrUYX8Z000XyRajnuCSt7oLBZfi', 'https://ui-avatars.com/api/?name=Oliver%20Queen&size=200'),
('ALU-085', 'Oliver', 'Wood', 'oliver.wood@edem.es', '$2b$12$GTqFWxWA.lQUYavtsCQKAuH/JB3HgHuBKT.rllABB7FXAKiCTKLiW', 'https://ui-avatars.com/api/?name=Oliver%20Wood&size=200'),
('ALU-086', 'Padma', 'Patil', 'padma.patil@edem.es', '$2b$12$qXokbHnZCrGAWojwYqNuFech257DZjt5VpalNkXDiIY/2DLHYhgZG', 'https://ui-avatars.com/api/?name=Padma%20Patil&size=200'),
('ALU-087', 'Padme', 'Amidala', 'padme.amidala@edem.es', '$2b$12$9LgzBIxR0Aw/u7hGIShx0es1eeisdeM96nRi9mzEAFlv5NUIFxV1m', 'https://ui-avatars.com/api/?name=Padme%20Amidala&size=200'),
('ALU-088', 'Parvati', 'Patil', 'parvati.patil@edem.es', '$2b$12$zrLFAVBASPvLe99XL0Us3OnOIkKf4Eq1AM1fHKMeDzA2WWIo5iwxO', 'https://ui-avatars.com/api/?name=Parvati%20Patil&size=200'),
('ALU-089', 'Peter', 'Parker', 'peter.parker@edem.es', '$2b$12$cAxxPyVoRBpesfZUdBRqzOCAzBtEnTqoK.Oq/zsh8JF6spaCzLL9W', 'https://ui-avatars.com/api/?name=Peter%20Parker&size=200'),
('ALU-090', 'Pippin', 'Took', 'pippin.took@edem.es', '$2b$12$a2V/6Nptze3Z12WvEYOzfO15X../vE2LRaVsWvD/L3y8meXoZcseS', 'https://ui-avatars.com/api/?name=Pippin%20Took&size=200'),
('ALU-091', 'Pocahontas', 'Powhatan', 'pocahontas.powhatan@edem.es', '$2b$12$tuUzet8sBH4WpV0I98mv4OWXiTmi8DHb0raq/7w7sFACJQvQn3Uom', 'https://ui-avatars.com/api/?name=Pocahontas%20Powhatan&size=200'),
('ALU-092', 'Podrick', 'Payne', 'podrick.payne@edem.es', '$2b$12$sleOQpNqDhHvKb0azXw08eAGeOOZV/Jlv4SNxE257rleWkkahx1Mu', 'https://ui-avatars.com/api/?name=Podrick%20Payne&size=200'),
('ALU-093', 'Poe', 'Dameron', 'poe.dameron@edem.es', '$2b$12$96JX7SX7kFTk7a0zqhjr5OodFocxzggp6ZkwO4ptZKSyeVami4Dli', 'https://ui-avatars.com/api/?name=Poe%20Dameron&size=200'),
('ALU-094', 'Rapunzel', 'Corona', 'rapunzel.corona@edem.es', '$2b$12$2yD0bQxiAhcaEoZshXe2w.kJjc/ywFZu0dzdQrjw1KET1aMSYnn0m', 'https://ui-avatars.com/api/?name=Rapunzel%20Corona&size=200'),
('ALU-095', 'Raya', 'Kumandra', 'raya.kumandra@edem.es', '$2b$12$16oXvH4pdGKDzTLnG/6h5.OUiiYap2D4.wRy3laVvwVpaN6c/9L46', 'https://ui-avatars.com/api/?name=Raya%20Kumandra&size=200'),
('ALU-096', 'Rey', 'Palpatine', 'rey.palpatine@edem.es', '$2b$12$vcsIlTvDQ62YBQ7y1Rl6VeSZ5hbBplXZIuzRpnpLlVAB6h1nb6GRW', 'https://ui-avatars.com/api/?name=Rey%20Palpatine&size=200'),
('ALU-097', 'Ron', 'Weasley', 'ron.weasley@edem.es', '$2b$12$oxqa7GP6kJ/Rp1W1hHYOdO5ZIwLM13pIBPTdqJckK9sQJVILavoNe', 'https://ui-avatars.com/api/?name=Ron%20Weasley&size=200'),
('ALU-098', 'Rosie', 'Cotton', 'rosie.cotton@edem.es', '$2b$12$FVdFAvKGwovtKtRleqqRq.7iiTcEzPaKfyYYyHI/dT7GS9YjsLLu2', 'https://ui-avatars.com/api/?name=Rosie%20Cotton&size=200'),
('ALU-099', 'Sabine', 'Wren', 'sabine.wren@edem.es', '$2b$12$kipPFt7ChsLkMeJT8jofke1Xg61GTm.oq6C6v4ItQpvWbdy7ABfwy', 'https://ui-avatars.com/api/?name=Sabine%20Wren&size=200'),
('ALU-100', 'Samwell', 'Tarly', 'samwell.tarly@edem.es', '$2b$12$lP0su5xS4jQtD8X2JgebOe8iWJ/NrIp9HPdbNiBTLNMGYiNbt/X5e', 'https://ui-avatars.com/api/?name=Samwell%20Tarly&size=200'),
('ALU-101', 'Samwise', 'Gamgee', 'samwise.gamgee@edem.es', '$2b$12$VUhV5oZnPWrusIELGtMJ7ucmGw8Zxnn1vtNKTLNq2UYvQlULouiuO', 'https://ui-avatars.com/api/?name=Samwise%20Gamgee&size=200'),
('ALU-102', 'Sansa', 'Stark', 'sansa.stark@edem.es', '$2b$12$J6VD62xcUPGPLuRRNJOAoe5qBhIDpZejtb2hBCwEKX2kpGaQT/w9G', 'https://ui-avatars.com/api/?name=Sansa%20Stark&size=200'),
('ALU-103', 'Scott', 'Lang', 'scott.lang@edem.es', '$2b$12$2JBLCdGe0fU312mb.f1Vx.vda5GuW8V87fzMbmiY4O52Oih8bCQcW', 'https://ui-avatars.com/api/?name=Scott%20Lang&size=200'),
('ALU-104', 'Seamus', 'Finnigan', 'seamus.finnigan@edem.es', '$2b$12$J7fA8.mTi7Ul//ZMs2QOQO0T.FZ/8RuqJ0JRNMoGWKDxLHbgbNPFS', 'https://ui-avatars.com/api/?name=Seamus%20Finnigan&size=200'),
('ALU-105', 'Selina', 'Kyle', 'selina.kyle@edem.es', '$2b$12$BacThGEWnxPcO674nAHJ7uDx0qHxOCua8gKUMhy0PSVuOzR28lGRe', 'https://ui-avatars.com/api/?name=Selina%20Kyle&size=200'),
('ALU-106', 'Stephen', 'Strange', 'stephen.strange@edem.es', '$2b$12$0zFjHzIJbPYIcneGuPNa/ONpGOc.Adr.DmtMlJbtj/Gfma5jdeLX.', 'https://ui-avatars.com/api/?name=Stephen%20Strange&size=200'),
('ALU-107', 'Steve', 'Rogers', 'steve.rogers@edem.es', '$2b$12$YEqeSIuEJ0uVqfHUPYyW7.Quq0puITziu9VojiKDp8Hc6uyY7lwkW', 'https://ui-avatars.com/api/?name=Steve%20Rogers&size=200'),
('ALU-108', 'Tauriel', 'Greenwood', 'tauriel.greenwood@edem.es', '$2b$12$N/ivxjaD/N7YtSkKdVlo0.S.BmhYUekDA9vqJPbLAUtj.CXtrE4MS', 'https://ui-avatars.com/api/?name=Tauriel%20Greenwood&size=200'),
('ALU-109', 'Theoden', 'Rohan', 'theoden.rohan@edem.es', '$2b$12$vVEmNCzORbUAElipsGUHL.UKRm2sQ3nuR7VTSL7k3mXWVprECd4e2', 'https://ui-avatars.com/api/?name=Theoden%20Rohan&size=200'),
('ALU-110', 'Theon', 'Greyjoy', 'theon.greyjoy@edem.es', '$2b$12$v87Aq8ESqUsptlsfGvNEX.37r16hSs6j83DqMXz4/dli7yzsgRbBK', 'https://ui-avatars.com/api/?name=Theon%20Greyjoy&size=200'),
('ALU-111', 'Thor', 'Odinson', 'thor.odinson@edem.es', '$2b$12$VDhPlVxmdxPZDRdfByrfgefk0jyGnHeIzK96TJh6zTt.T0qAa4DDO', 'https://ui-avatars.com/api/?name=Thor%20Odinson&size=200'),
('ALU-112', 'Tiana', 'Bayou', 'tiana.bayou@edem.es', '$2b$12$k7tEEG0uUZW79HdMSxt6oeAHz0qsQrMqW7aur2Fc/RTGr3qkJbp6y', 'https://ui-avatars.com/api/?name=Tiana%20Bayou&size=200'),
('ALU-113', 'Tony', 'Stark', 'tony.stark@edem.es', '$2b$12$77JAYwAaSwuCl/kuoiW4d.CHdPIhyrx6Xm8/AaC79wn04YI75ZFu.', 'https://ui-avatars.com/api/?name=Tony%20Stark&size=200'),
('ALU-114', 'Tormund', 'Giantsbane', 'tormund.giantsbane@edem.es', '$2b$12$mzgREpYlNL4KbMm5RBeD3.Ef1LTGi.r9IZJhszCuxFr0DxcaOR4Gm', 'https://ui-avatars.com/api/?name=Tormund%20Giantsbane&size=200'),
('ALU-115', 'Tyrion', 'Lannister', 'tyrion.lannister@edem.es', '$2b$12$D//ds4Cmm4p9HN0x/Ai2ZOhpxkWRv/HJYzYGtbHXXula9FXaelBTi', 'https://ui-avatars.com/api/?name=Tyrion%20Lannister&size=200'),
('ALU-116', 'Victor', 'Stone', 'victor.stone@edem.es', '$2b$12$0J35XcXvHxM0kSPngjTwnumbphXmigeJ7ovtRCwNaOUGxpGdDsbJu', 'https://ui-avatars.com/api/?name=Victor%20Stone&size=200'),
('ALU-117', 'Wanda', 'Maximoff', 'wanda.maximoff@edem.es', '$2b$12$9mzvrlPzMZTgfjO915fZw.w3Vt.862jN0KoyhL4s5aTpbg3Lyt47y', 'https://ui-avatars.com/api/?name=Wanda%20Maximoff&size=200'),
('ALU-118', 'Woody', 'Pride', 'woody.pride@edem.es', '$2b$12$xub.zCN0SK8sChPunBrtFOZ3u6GNY81XgB4BNf4qT6qEiQFel1f1q', 'https://ui-avatars.com/api/?name=Woody%20Pride&size=200'),
('ALU-119', 'Ygritte', 'Wildling', 'ygritte.wildling@edem.es', '$2b$12$K80D40mn9reVGqwyOkEIBuu.S0jh5QNkIlJfSIcTNlLUxJPywEaw6', 'https://ui-avatars.com/api/?name=Ygritte%20Wildling&size=200'),
('ALU-120', 'Yoda', 'Dagobah', 'yoda.dagobah@edem.es', '$2b$12$jSpTfurTC9RncbIPooCMY./sh9/OxzalGbQc9MF5Rt7clddbOj8L6', 'https://ui-avatars.com/api/?name=Yoda%20Dagobah&size=200');


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
('PER-001', 'Andrea', 'Soler', 'andrea.soler@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Andrea%20Soler&size=200', '$2b$12$IriqmhhYrOnw1pkFcAF.aO7IIgyqs/HnJlLxdfC1QRH4USb/4PyGS'),
('PER-002', 'Luis', 'Marín', 'luis.marin@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Luis%20Mar%C3%ADn&size=200', '$2b$12$g3EcZJ4w67SnNiX1sTW0xuEM2nF/E/sHd2VcZIjbD3B282JOK/IXa'),
('PER-003', 'Miguel', 'Herrera', 'miguel.herrera@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Miguel%20Herrera&size=200', '$2b$12$xBgVatarzgScXNE40/UL/O8sHmLXtuNaaEvG2aogv9qlnl86k7AZK'),
('PER-004', 'Sara', 'Reyes', 'sara.reyes@edem.es', 'Coordinador', 'https://ui-avatars.com/api/?name=Sara%20Reyes&size=200', '$2b$12$M/LhhD29/ANvk/Q/leBUAeys09Y5z6XW6ZIZB4Qdu9AyTjxppZ53S');


-- fabricate-flush


INSERT INTO "profesores" ("id_profesor", "nombre", "apellido", "correo", "url_foto", "contrasena") VALUES
('PROF-001', 'Alberto', 'Gil', 'alberto.gil@edem.es', 'https://ui-avatars.com/api/?name=Alberto%20Gil&size=200', '$2b$12$m1WkD3OMt1LHIdi6Krw64.h2cCkoAzAayGpK/5.zEmYzbhnlKNxoe'),
('PROF-002', 'Ana', 'Fernández', 'ana.fernandez@edem.es', 'https://ui-avatars.com/api/?name=Ana%20Fern%C3%A1ndez&size=200', '$2b$12$Hnq0Fr4.O5FH/THg8LG19u/JCbDuVsGnVx.ahzWsFiSpbQIoGtShK'),
('PROF-003', 'Andrés', 'Herrero', 'andres.herrero@edem.es', 'https://ui-avatars.com/api/?name=Andr%C3%A9s%20Herrero&size=200', '$2b$12$dL8rkJDJXhwPTII/3eWozec7TeVP58zPXFRub9WWiLN8T0pP/XtZm'),
('PROF-004', 'Carlos', 'García', 'carlos.garcia@edem.es', 'https://ui-avatars.com/api/?name=Carlos%20Garc%C3%ADa&size=200', '$2b$12$5c7oTIgeV.6fnr6lpfYyC.jeZ8geycGb1ud.8zJfUfbaeIIdzhmEC'),
('PROF-005', 'Carmen', 'Álvarez', 'carmen.alvarez@edem.es', 'https://ui-avatars.com/api/?name=Carmen%20%C3%81lvarez&size=200', '$2b$12$Sn4JNdat65gR8A5u2uS3TukSmnatHzH.ilo2/Vn.R30IvqfD9k4R.'),
('PROF-006', 'Cristina', 'Ortiz', 'cristina.ortiz@edem.es', 'https://ui-avatars.com/api/?name=Cristina%20Ortiz&size=200', '$2b$12$skCyLk77TXu31kwoQw7r1eLgEdYgywqtnusnaoe2ZUJLvPEBd9scW'),
('PROF-007', 'Daniel', 'Morales', 'daniel.morales@edem.es', 'https://ui-avatars.com/api/?name=Daniel%20Morales&size=200', '$2b$12$.AeRfGbFPgi4m0f06dZJfe0vB41df7FlsFhX.B2bjpIiX0mKCqt4y'),
('PROF-008', 'Diego', 'Ruiz', 'diego.ruiz@edem.es', 'https://ui-avatars.com/api/?name=Diego%20Ruiz&size=200', '$2b$12$R5ehGLNLJf1pUqz3ayL9FeSHi0t3vc/V3ZGLrP1Wvfz0S5GnCPRZC'),
('PROF-009', 'Elena', 'Moreno', 'elena.moreno@edem.es', 'https://ui-avatars.com/api/?name=Elena%20Moreno&size=200', '$2b$12$JXJWFuV4h4CEt8nuvh/rSuW/aoo1UKU3BEi5Ca3b2wmiL8IjGir1i'),
('PROF-010', 'Fernando', 'Castro', 'fernando.castro@edem.es', 'https://ui-avatars.com/api/?name=Fernando%20Castro&size=200', '$2b$12$glU2ufbOZSHPh6pksw2I8eI7zzw7tz9hwkUncIrTCekwhkB2unKjK'),
('PROF-011', 'Francisco', 'Romero', 'francisco.romero@edem.es', 'https://ui-avatars.com/api/?name=Francisco%20Romero&size=200', '$2b$12$QiE.iM/CC0tR5Ao7/nTb6ekx3PzEDPOM/..D6QK2rjW1aEqDaV2xO'),
('PROF-012', 'Isabel', 'Navarro', 'isabel.navarro@edem.es', 'https://ui-avatars.com/api/?name=Isabel%20Navarro&size=200', '$2b$12$p7Pijvb2JYpHYiUMNqpA8OWjq3NhXE7xBzHf/zBVt4Q3xySsg22c.'),
('PROF-013', 'Javier', 'Martín', 'javier.martin@edem.es', 'https://ui-avatars.com/api/?name=Javier%20Mart%C3%ADn&size=200', '$2b$12$Dmg80.9Mn3StILUtn2TyW.MfOZxE6NoFP5Uqd37fcLz8JrnBSoLZu'),
('PROF-014', 'Laura', 'Torres', 'laura.torres@edem.es', 'https://ui-avatars.com/api/?name=Laura%20Torres&size=200', '$2b$12$CWlBEh7jv3qbMlL.I9HccOlOkd.aeaeHF5oUhUp5kiA1FKIvXajkm'),
('PROF-015', 'Lucía', 'Blanco', 'lucia.blanco@edem.es', 'https://ui-avatars.com/api/?name=Luc%C3%ADa%20Blanco&size=200', '$2b$12$nvyHj8NeT1TEsXj8tatCteq07E8GHQAVoTZWYtSN5Cd.0wOAcSUOS'),
('PROF-016', 'Manuel', 'Ramírez', 'manuel.ramirez@edem.es', 'https://ui-avatars.com/api/?name=Manuel%20Ram%C3%ADrez&size=200', '$2b$12$h8cvbFSY2e/ljPY4xo6w8e5j0RzVsWQuEUwbM4unOO4kpd9fK335u'),
('PROF-017', 'Marta', 'Delgado', 'marta.delgado@edem.es', 'https://ui-avatars.com/api/?name=Marta%20Delgado&size=200', '$2b$12$8GZ9v37lbixkW.remw9PT.Wh9oEHVQMBKctM/QyVxHxi/e5qiCXn6'),
('PROF-018', 'María', 'López', 'maria.lopez@edem.es', 'https://ui-avatars.com/api/?name=Mar%C3%ADa%20L%C3%B3pez&size=200', '$2b$12$doATjuuVasNMlVREryvrQ.kJjyzuAjt9SqopIxptp4GCgyRi5yGRy'),
('PROF-019', 'Pablo', 'Vega', 'pablo.vega@edem.es', 'https://ui-avatars.com/api/?name=Pablo%20Vega&size=200', '$2b$12$HhIEOAdK8piS4o65kILiD.hKLqXJrbKQe.Dl7bBkkOd9Tk8rKuDVi'),
('PROF-020', 'Patricia', 'Serrano', 'patricia.serrano@edem.es', 'https://ui-avatars.com/api/?name=Patricia%20Serrano&size=200', '$2b$12$LqPzVpo0F5UEMBb5tX2vBucHsVmx2dyJj5Sz29umc1Z8.RLHpqNkm'),
('PROF-021', 'Pedro', 'Sánchez', 'pedro.sanchez@edem.es', 'https://ui-avatars.com/api/?name=Pedro%20S%C3%A1nchez&size=200', '$2b$12$Q.HdSInBFZCa0OJTw6u3aO51xcbP7nHUVi5UgzZlTi6ZOqMFdz70G'),
('PROF-022', 'Raúl', 'Jiménez', 'raul.jimenez@edem.es', 'https://ui-avatars.com/api/?name=Ra%C3%BAl%20Jim%C3%A9nez&size=200', '$2b$12$v6X7kowZroQYR.upHRBdmuHenL4vMsMV7y33aPw9wMVNcaZ6LW9UW'),
('PROF-023', 'Roberto', 'Díaz', 'roberto.diaz@edem.es', 'https://ui-avatars.com/api/?name=Roberto%20D%C3%ADaz&size=200', '$2b$12$T2VPIwA.Y.opwaWf9MypUuDz7q9nnBirI7LdKZEjh6PAFtO2i3Xx2'),
('PROF-024', 'Sofía', 'Molina', 'sofia.molina@edem.es', 'https://ui-avatars.com/api/?name=Sof%C3%ADa%20Molina&size=200', '$2b$12$VUnd3ChaJWWPVkzhl/CZMuIjR7IxvtS372ix6AtVcvza0mWI05uTC'),
('PROF-025', 'Teresa', 'Peña', 'teresa.pena@edem.es', 'https://ui-avatars.com/api/?name=Teresa%20Pe%C3%B1a&size=200', '$2b$12$K9Tpsft2mGs.sQZdTmm9be9vO/TwJ2ONBxTyRotZYSV168T8qLGSC');


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
