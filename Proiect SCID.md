#engineering #integrated_digital_circuits 
# Tema proiect
	Proiectati un ceas de mana cu mai multe functii, afisare ora, alarma, cronometru, timer. Acesta are trei butoane cu care este utilizat, b1, b2 respectiv b3.

# Cerinte proiect
- [x] Butoane debounce-uite
- [x] Reset global b1xb2xb3 (opt sa se apese mai mult)
- [x] Starile automatului
	- [x] 1.Pornire
	- [x] 2.Afisare ora (la setare ora sa se apese mai mult butonul *optional*)
	- [x] 3.Setare alarma (la setare ora sa se apese mai mult butonul *optional*)
	- [x] 4.Setare timer (la setare ora sa se apese mai mult butonul *optional*)
	- [x] 5.Cronometru
	- [x] Starile aferente: Setare ora, setare minute, secunde implicit la 00.
- [ ] Circuitele aferente
	- [ ] Ceasul
		- [x] Div frecventa T=1s
		- [ ] Cronometru
		- [ ] Timer
			- [ ] alarma la final
		- [ ] Alarma
			- [ ] timp funct 1 min implicit si oprire la buton
			- [ ] Stare de on/off cu mesaj corespunzator
			- [ ] Comparator cu ora ceas
			- [ ] Setare ora, minute
			- [ ] Circuitul de alarma propriu zis/flag pt circ de alarma
				O sa fac led urile de la butoane sa palpaie progresiv ca la semanlizarea de la masina.
	- [ ] Driver display
		- [ ] Afisare ora
			- [ ] afisare normala ora
			- [ ] afisare cu palpait la setare ora
		- [ ] Afisare alarma
			- [ ] afisare stare alarma on/off (on va arata ora alarmei si off va arata O F F)
			- [ ] afisare la setare  ora cu palpait
		- [ ] Afisare cronometru
			- [ ] afisare normala cand merge si este oprit
		- [ ] Afisare timer
			- [ ] afisare normala cand merge si este oprit
			- [ ] palpait cand ajunge la 00:00:00

# Jurnal proiect

- Day 1
	Am facut diagramele si schema bloc si am inceput proiectul in vivado. Am creat sursa la ceas si debouncer si am implementat doar deBouncerul. M-am chinuti cam mult sa scriu debouncerul doar ca sa scriu de mana, nu cred ca afost folositor.
- Day 2
	Am rafinat schema bloc si modul cum vreau sa fie facut ceasul de mana plus am creat un bucket list mai detaliat (mai sus). Am decis sa fac automatul, ceasul si displayul separate. Ceasul are toate functiile lui, tine ora, are alarma, timer si cronometru. Ele sunt selectate in functie de starea automatului si va transmite datele corespunzatoare automatului care le inainteaza la display (cut the middleman maybe?)
	Am mappat debouncerele si butoanele, am facut rst la debouncere (care cred ca intra intr o bucla de rst care nu ma lasa sa dau rst global)
	Am initializat starile automatului si am creat si restul starilor. Am folosit un top_state pt a sti care e starea din care am pornit la set_hr si set_min.
	Mai trebuie sa explicitez starile pt fiecare si sa le fac procesele, dupa ma apuc de ceas si displayul 7 seg.
- Day 3
	Am renuntat la ideea de a avea mai putine stari, era prea complicata si incepea sa ma oboseasca si nici nu terminam proiectul. Am desenat diagrama de tranzitii in detaliu si cu semnalele aferente, cred ca a iesit mult mai bine.
	Am facut si divizorul de frecventa pentru ceas (T=1s) intr-un fisier de design separat. O sa fac la fel si pentru cat se poate din restul circuitelor aferente. Imi este mai usor sa ma descurc cu un proiect de aceasta dimensiune. 
	O sa modific si bucket listul pentru ca nu cred ca mai este la curent cu ce vreau sa ajunga proiectul.
