--DROP SCHEMA public CASCADE;
--CREATE SCHEMA public; (if needed restart database )


CREATE DATABASE rpggame;

-- tables and constraints

-- Classes Table
CREATE TABLE Classes (
    class_id SERIAL PRIMARY KEY,
    class_name VARCHAR(45) NOT NULL,
    action_points_modifier NUMERIC NOT NULL CHECK (action_points_modifier >= 0),
    damage_modifier NUMERIC NOT NULL CHECK (damage_modifier >= 0),
    inventory_bonus NUMERIC NOT NULL CHECK (inventory_bonus >= 0)
);

-- Character Table
CREATE TABLE Character (
    character_id SERIAL PRIMARY KEY,
    character_name VARCHAR(45) NOT NULL,
    action_points NUMERIC NOT NULL CHECK (action_points >= 0),
    armor_class NUMERIC NOT NULL CHECK (armor_class >= 0),
    class_id INT NOT NULL,
    strength NUMERIC NOT NULL CHECK (strength >= 0),
    dexterity NUMERIC NOT NULL CHECK (dexterity >= 0),
    constitution NUMERIC NOT NULL CHECK (constitution >= 0),
    intelligence NUMERIC NOT NULL CHECK (intelligence >= 0),
    max_health NUMERIC NOT NULL CHECK (max_health >= 0),
    health NUMERIC NOT NULL CHECK (health >= 0),
    inventory_capacity NUMERIC NOT NULL CHECK (inventory_capacity >= 0),
    inventory_capacity_reached NUMERIC NOT NULL CHECK (
        inventory_capacity_reached >= 0 AND 
        inventory_capacity_reached <= inventory_capacity
    ),
    FOREIGN KEY (class_id) REFERENCES Classes(class_id)
);

-- Spells Table
CREATE TABLE Spells (
    spell_id SERIAL PRIMARY KEY,
    spell_name VARCHAR(45) NOT NULL,
    damage NUMERIC NOT NULL CHECK (damage >= 0),
    action_points_cost NUMERIC NOT NULL CHECK (action_points_cost >= 0),
    required_strength NUMERIC NOT NULL CHECK (required_strength >= 0),
    required_dexterity NUMERIC NOT NULL CHECK (required_dexterity >= 0),
    required_constitution NUMERIC NOT NULL CHECK (required_constitution >= 0),
    required_intelligence NUMERIC NOT NULL CHECK (required_intelligence >= 0),
    modifying_attribute VARCHAR(45) NOT NULL CHECK (
        modifying_attribute IN ('strength', 'dexterity', 'constitution', 'intelligence')
    )
);

-- Items Table
CREATE TABLE Items (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(45) NOT NULL,
    damage NUMERIC NOT NULL CHECK (damage >= 0),
    weight NUMERIC NOT NULL CHECK (weight >= 0),
    action_points_cost NUMERIC NOT NULL CHECK (action_points_cost >= 0)
);

-- Character_has_Items Table
CREATE TABLE Character_has_Items (
    character_id INT NOT NULL,
    item_id INT NOT NULL,
    PRIMARY KEY (character_id, item_id),
    FOREIGN KEY (character_id) REFERENCES Character(character_id),
    FOREIGN KEY (item_id) REFERENCES Items(item_id)
);

-- Combats Table
CREATE TABLE Combats (
    combat_id SERIAL PRIMARY KEY,
    char1_id INT NOT NULL,
    char2_id INT NOT NULL,
    winner_id INT,
    FOREIGN KEY (char1_id) REFERENCES Character(character_id),
    FOREIGN KEY (char2_id) REFERENCES Character(character_id),
    FOREIGN KEY (winner_id) REFERENCES Character(character_id)
);

-- Arena_items_has_Items Table
CREATE TABLE Arena_items_has_Items (
    items_id INT NOT NULL,
    combat_id INT NOT NULL,
    PRIMARY KEY (items_id, combat_id),
    FOREIGN KEY (items_id) REFERENCES Items(item_id),
    FOREIGN KEY (combat_id) REFERENCES Combats(combat_id)
);

-- Combat_log Table
CREATE TABLE Combat_log (
    log_id SERIAL PRIMARY KEY,
    combat_id INT NOT NULL,
    round_num INT NOT NULL CHECK (round_num >= 0),
    event_num INT NOT NULL CHECK (event_num >= 0),
    event_type VARCHAR(45) NOT NULL CHECK (
        event_type IN ('enter_combat', 'spell_attack', 'loot_item', 'rest_character', 'reset_round', 'throw_item', 'attack_item')
    ),
    char1_id INT NOT NULL CHECK (char1_id >= 0),
    char2_id INT CHECK (char2_id >= 0),
    char1_ap NUMERIC  CHECK (char1_ap >= 0),
    char1_health NUMERIC CHECK (char1_health >= 0),
    char2_ap NUMERIC  CHECK (char2_ap >= 0),
    char2_health NUMERIC  CHECK (char2_health >= 0),
    d20_value INT CHECK (d20_value BETWEEN 1 AND 20),
    attack_damage NUMERIC CHECK (attack_damage >= 0),
    item_id INT,
    spell_id INT,
    char1_ap_after NUMERIC CHECK (char1_ap_after >= 0),
    char2_ap_after NUMERIC  CHECK (char2_ap_after >= 0),
    char1_health_after NUMERIC CHECK (char1_health_after >= 0),
    char2_health_after NUMERIC CHECK (char2_health_after >= 0),
    FOREIGN KEY (combat_id) REFERENCES Combats(combat_id),
    FOREIGN KEY (char1_id) REFERENCES Character(character_id),
    FOREIGN KEY (char2_id) REFERENCES Character(character_id),
    FOREIGN KEY (item_id) REFERENCES Items(item_id),
    FOREIGN KEY (spell_id) REFERENCES Spells(spell_id)
);

-- Item_Ownership_History Table
CREATE TABLE Item_Ownership_History (
    history_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    character_id INT NOT NULL,
    log_id INT NOT NULL,
    FOREIGN KEY (item_id) REFERENCES Items(item_id),
    FOREIGN KEY (character_id) REFERENCES Character(character_id),
    FOREIGN KEY (log_id) REFERENCES Combat_log(log_id)
);

-- Arena_Items_History Table
CREATE TABLE Arena_Items_History (
    arena_history_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    log_id INT NOT NULL,
    FOREIGN KEY (item_id) REFERENCES Items(item_id),
    FOREIGN KEY (log_id) REFERENCES Combat_log(log_id)
);





--indexes
CREATE INDEX idx_combatlog_combat_id ON Combat_log(combat_id);
CREATE INDEX idx_combatlog_char1_id ON Combat_log(char1_id);
CREATE INDEX idx_combatlog_char2_id ON Combat_log(char2_id);
CREATE INDEX idx_combatlog_item_id ON Combat_log(item_id);
CREATE INDEX idx_combatlog_spell_id ON Combat_log(spell_id);
CREATE INDEX idx_combatlog_event_type ON Combat_log(event_type);

CREATE INDEX idx_combats_char1_id ON Combats(char1_id);
CREATE INDEX idx_combats_char2_id ON Combats(char2_id);
CREATE INDEX idx_combats_winner_id ON Combats(winner_id);

CREATE INDEX idx_character_items ON Character_has_Items(character_id);
CREATE INDEX idx_items_character ON Character_has_Items(item_id);

CREATE INDEX idx_arena_items_combat ON Arena_items_has_Items(combat_id);
CREATE INDEX idx_arena_items_id ON Arena_items_has_Items(items_id);

CREATE INDEX idx_item_ownership_item_id ON Item_Ownership_History(item_id);
CREATE INDEX idx_item_ownership_character_id ON Item_Ownership_History(character_id);
CREATE INDEX idx_item_ownership_log_id ON Item_Ownership_History(log_id);

CREATE INDEX idx_arena_history_item_id ON Arena_Items_History(item_id);
CREATE INDEX idx_arena_history_log_id ON Arena_Items_History(log_id);

CREATE INDEX idx_spells_mod_attr ON Spells(modifying_attribute);

CREATE INDEX idx_character_class_id ON Character(class_id);

CREATE INDEX idx_combatlog_combat_round ON Combat_log(combat_id, round_num DESC);


--views
CREATE OR REPLACE VIEW view_combat_state AS
SELECT distinct
    co.combat_id,
    cl.round_num,
    ch.character_id,
    ch.character_name,
    ch.action_points
FROM Combats co
JOIN combat_log cl ON cl.combat_id = co.combat_id
JOIN Character ch ON ch.character_id IN (co.char1_id, co.char2_id)
WHERE co.winner_id IS NULL
  AND cl.round_num = (
        SELECT MAX(cl2.round_num)
        FROM combat_log cl2
        WHERE cl2.combat_id = co.combat_id
);



--
CREATE OR REPLACE VIEW view_most_damage AS
SELECT 
    c.character_id, 
    c.character_name,
    SUM(COALESCE(cl.attack_damage, 0)) AS total_damage
FROM character c
LEFT JOIN combat_log cl ON c.character_id = cl.char1_id
GROUP BY c.character_id, c.character_name
ORDER BY total_damage DESC;


--
CREATE OR REPLACE VIEW view_strongest_characters AS
SELECT 
    c.character_id,
    c.character_name,
    SUM(COALESCE(cl.attack_damage, 0)) AS total_damage_done,
    c.health AS remaining_health,
    (
        SUM(COALESCE(cl.attack_damage, 0)) + c.health
    ) AS performance_score
FROM character c
LEFT JOIN combat_log cl ON c.character_id = cl.char1_id
GROUP BY c.character_id, c.character_name, c.health
ORDER BY performance_score DESC;


--
CREATE OR REPLACE VIEW view_combat_damage AS
SELECT 
    combat_id,
    SUM(COALESCE(attack_damage, 0)) AS total_combat_damage
FROM combat_log
GROUP BY combat_id
ORDER BY total_combat_damage DESC;


--
CREATE OR REPLACE VIEW view_spell_statistics AS
SELECT 
    s.spell_id,
    s.spell_name,
    COUNT(cl.spell_id) AS usage_count,
    SUM(COALESCE(cl.attack_damage, 0)) AS total_damage
FROM spells s
LEFT JOIN combat_log cl ON s.spell_id = cl.spell_id
GROUP BY s.spell_id, s.spell_name
ORDER BY total_damage DESC;

---------------------------------------------------------------------------
--functions and procedures
---------------------------------------------------------------------------

--enter combat
CREATE OR REPLACE FUNCTION sp_enter_combat (
    p_combat_id INT,
    p_char1_id INT,
    p_char2_id INT
) RETURNS VOID AS $$
DECLARE
    v_char1_ap NUMERIC;
    v_char1_health NUMERIC;
    v_char2_ap NUMERIC;
    v_char2_health NUMERIC;
    v_item_id INT;
    v_log_id INT;
    v_combat_id INT;

    v_conflict1 INT;
    v_conflict2 INT;

    -- Pre kapacitu
    v_char1_base_capacity NUMERIC;
    v_char2_base_capacity NUMERIC;
    v_char1_bonus NUMERIC;
    v_char2_bonus NUMERIC;
BEGIN
    -- Check for conflicts
    SELECT COUNT(*) INTO v_conflict1
    FROM Combats
    WHERE winner_id IS NULL AND (char1_id = p_char1_id OR char2_id = p_char1_id);

    SELECT COUNT(*) INTO v_conflict2
    FROM Combats
    WHERE winner_id IS NULL AND (char1_id = p_char2_id OR char2_id = p_char2_id);

    IF v_conflict1 > 0 THEN
        RAISE EXCEPTION 'Character % is already in an ongoing combat.', p_char1_id;
    ELSIF v_conflict2 > 0 THEN
        RAISE EXCEPTION 'Character % is already in an ongoing combat.', p_char2_id;
    END IF;

    -- 1. Insert new combat
    INSERT INTO Combats (combat_id, char1_id, char2_id, winner_id)
    VALUES (p_combat_id, p_char1_id, p_char2_id, NULL);

    -- 2. Get characters' action points and health
    SELECT action_points, health, inventory_capacity INTO v_char1_ap, v_char1_health, v_char1_base_capacity
    FROM Character WHERE character_id = p_char1_id;

    SELECT action_points, health, inventory_capacity INTO v_char2_ap, v_char2_health, v_char2_base_capacity
    FROM Character WHERE character_id = p_char2_id;

    -- 3. Get inventory bonus for both characters
    SELECT inventory_bonus INTO v_char1_bonus
    FROM Character ch JOIN Classes cl ON ch.class_id = cl.class_id
    WHERE ch.character_id = p_char1_id;

    SELECT inventory_bonus INTO v_char2_bonus
    FROM Character ch JOIN Classes cl ON ch.class_id = cl.class_id
    WHERE ch.character_id = p_char2_id;

    -- 4. Update inventory_capacity with bonus
    UPDATE Character
    SET inventory_capacity = v_char1_base_capacity + v_char1_bonus
    WHERE character_id = p_char1_id;

    UPDATE Character
    SET inventory_capacity = v_char2_base_capacity + v_char2_bonus
    WHERE character_id = p_char2_id;

    -- 5. Confirm latest combat_id
    SELECT combat_id INTO v_combat_id
    FROM Combats
    ORDER BY combat_id DESC
    LIMIT 1;

    -- 6. Insert into Combat_log 
    INSERT INTO Combat_log (
        combat_id, round_num, event_num, event_type,
        char1_id, char2_id,
        char1_ap, char2_ap,
        char1_health, char2_health,
        d20_value, attack_damage,
        item_id, spell_id,
        char1_ap_after, char2_ap_after,
        char1_health_after, char2_health_after
    ) VALUES (
        v_combat_id, 1, 1, 'enter_combat',
        p_char1_id, p_char2_id,
        v_char1_ap, v_char2_ap,
        v_char1_health, v_char2_health,
        NULL, NULL,
        NULL, NULL,
        v_char1_ap, v_char2_ap,
        v_char1_health, v_char2_health
    );

    -- 7. Get log_id of the 'enter_combat' event
    SELECT log_id INTO v_log_id
    FROM Combat_log
    WHERE combat_id = v_combat_id AND event_type = 'enter_combat'
    ORDER BY log_id DESC
    LIMIT 1;

    -- 8. Choose 3 unowned items and not already in any ongoing arena
    FOR v_item_id IN (
        SELECT i.item_id 
        FROM Items i
        LEFT JOIN Character_has_Items chi ON i.item_id = chi.item_id
        LEFT JOIN Arena_items_has_Items aih ON i.item_id = aih.items_id
        LEFT JOIN Combats c ON aih.combat_id = c.combat_id AND c.winner_id IS NULL
        WHERE chi.item_id IS NULL AND c.combat_id IS NULL
        ORDER BY random()
        LIMIT 3
    ) LOOP
        INSERT INTO Arena_items_has_Items (items_id, combat_id)
        VALUES (v_item_id, v_combat_id);
    END LOOP;

    -- 9. Insert all current arena items into Arena_Items_History for this combat
    INSERT INTO Arena_Items_History (item_id, log_id)
    SELECT items_id, v_log_id
    FROM Arena_items_has_Items
    WHERE combat_id = v_combat_id;

    -- 10. Log current ownership for character 1
    INSERT INTO Item_Ownership_History (item_id, character_id, log_id)
    SELECT item_id, p_char1_id, v_log_id
    FROM Character_has_Items
    WHERE character_id = p_char1_id;

    -- 11. Log current ownership for character 2
    INSERT INTO Item_Ownership_History (item_id, character_id, log_id)
    SELECT item_id, p_char2_id, v_log_id
    FROM Character_has_Items
    WHERE character_id = p_char2_id;

END;
$$ LANGUAGE plpgsql;




--rest character
CREATE OR REPLACE FUNCTION sp_rest_character (
    p_character1_id INT,
    p_character2_id INT
) RETURNS VOID AS $$
DECLARE
    -- char 1
    v_dexterity1 NUMERIC;
    v_intelligence1 NUMERIC;
    v_ap_modifier1 NUMERIC;
    v_max_health1 NUMERIC;
    v_new_ap1 NUMERIC;
    v_current_health1 NUMERIC;

    -- char 2
    v_dexterity2 NUMERIC;
    v_intelligence2 NUMERIC;
    v_ap_modifier2 NUMERIC;
    v_max_health2 NUMERIC;
    v_new_ap2 NUMERIC;
    v_current_health2 NUMERIC;

    -- Log and combat info
    v_combat_id INT;
    v_round_num INT;
    v_event_num INT;
    v_winner_id INT;
    v_new_log_id INT;
BEGIN
    -- 1. Get combat_id for the ongoing combat between the given characters
    SELECT combat_id INTO v_combat_id
    FROM Combats
    WHERE ((char1_id = p_character1_id AND char2_id = p_character2_id)
        OR (char2_id = p_character1_id AND char1_id = p_character2_id))
      AND winner_id IS NULL
    ORDER BY combat_id DESC
    LIMIT 1;

    -- 2. Get latest combat_log for this combat_id
    SELECT round_num, event_num INTO v_round_num, v_event_num
    FROM combat_log
    WHERE combat_id = v_combat_id
    ORDER BY log_id DESC
    LIMIT 1;

    -- Increment the event number for the new log entry
    v_event_num := v_event_num + 1;

    -- 3. Get current health for both characters
    SELECT health INTO v_current_health1 FROM character WHERE character_id = p_character1_id;
    SELECT health INTO v_current_health2 FROM character WHERE character_id = p_character2_id;

    -- 4. Determine the winner (the one with health > 0)
    IF v_current_health1 > 0 THEN
        v_winner_id := p_character1_id;
    ELSIF v_current_health2 > 0 THEN
        v_winner_id := p_character2_id;
    ELSE
        v_winner_id := 0; -- Optional: no winner, if both <= 0
    END IF;

    -- 5. Update winner in Combats
    UPDATE Combats
    SET winner_id = v_winner_id
    WHERE combat_id = v_combat_id;

    -- 6. Get character 1 stats for new AP
    SELECT ch.dexterity, ch.intelligence, ch.max_health, c.action_points_modifier
    INTO v_dexterity1, v_intelligence1, v_max_health1, v_ap_modifier1
    FROM character ch
    JOIN classes c ON ch.class_id = c.class_id
    WHERE ch.character_id = p_character1_id;

    v_new_ap1 := (v_dexterity1 + v_intelligence1) * v_ap_modifier1;

    -- 7. Get character 2 stats for new AP
    SELECT ch.dexterity, ch.intelligence, ch.max_health, c.action_points_modifier
    INTO v_dexterity2, v_intelligence2, v_max_health2, v_ap_modifier2
    FROM character ch
    JOIN classes c ON ch.class_id = c.class_id
    WHERE ch.character_id = p_character2_id;

    v_new_ap2 := (v_dexterity2 + v_intelligence2) * v_ap_modifier2;

    -- 8. Update characters' health and AP
    UPDATE character
    SET health = v_max_health1,
        action_points = v_new_ap1
    WHERE character_id = p_character1_id;

    UPDATE character
    SET health = v_max_health2,
        action_points = v_new_ap2
    WHERE character_id = p_character2_id;

    -- 9. Remove all items from the arena for this combat
    DELETE FROM Arena_items_has_Items
    WHERE combat_id = v_combat_id;

    -- 10. Log the rest event in combat_log
    INSERT INTO combat_log (
        combat_id, round_num, event_num, event_type,
        char1_id, char2_id,
        char1_ap, char2_ap,
        char1_health, char2_health,
        d20_value, attack_damage,
        item_id, spell_id,
        char1_ap_after, char2_ap_after,
        char1_health_after, char2_health_after
    ) VALUES (
        v_combat_id, v_round_num, v_event_num, 'rest_character',
        p_character1_id, p_character2_id,
        NULL, NULL,
        NULL, NULL,
        NULL, NULL,
        NULL, NULL,
        v_new_ap1, v_new_ap2,
        v_max_health1, v_max_health2
    );

    -- 11. Get new log_id for this rest event
    SELECT log_id INTO v_new_log_id
    FROM combat_log
    WHERE combat_id = v_combat_id AND char1_id = p_character1_id AND char2_id = p_character2_id
    ORDER BY log_id DESC
    LIMIT 1;

    -- 12. Log current ownership for character 1
    INSERT INTO Item_Ownership_History (item_id, character_id, log_id)
    SELECT item_id, p_character1_id, v_new_log_id
    FROM Character_has_Items
    WHERE character_id = p_character1_id;

    -- 13. Log current ownership for character 2
    INSERT INTO Item_Ownership_History (item_id, character_id, log_id)
    SELECT item_id, p_character2_id, v_new_log_id
    FROM Character_has_Items
    WHERE character_id = p_character2_id;

END;
$$ LANGUAGE plpgsql;



--reset round
CREATE OR REPLACE FUNCTION sp_reset_round (
    p_combat_id INT
) RETURNS VOID AS $$
DECLARE
    -- Characters
    v_char1_id INT;
    v_char2_id INT;
    v_winner_id INT;

    -- Stats char1
    v_dexterity1 NUMERIC;
    v_intelligence1 NUMERIC;
    v_ap_modifier1 NUMERIC;
    v_new_ap1 NUMERIC;
    v_char1_health NUMERIC;

    -- Stats char2
    v_dexterity2 NUMERIC;
    v_intelligence2 NUMERIC;
    v_ap_modifier2 NUMERIC;
    v_new_ap2 NUMERIC;
    v_char2_health NUMERIC;

    -- Combat log and arena
    v_new_log_id INT;
    v_round_num INT;
	v_combat_id INT;
BEGIN

	IF NOT EXISTS (
        SELECT 1 FROM Combats WHERE combat_id = p_combat_id
    ) THEN
        RAISE EXCEPTION 'Combat % does not exist.', p_combat_id;
    END IF;
	
    -- 1. Get characters for the combat and check if combat is still ongoing
    SELECT combat_id, char1_id, char2_id, winner_id INTO v_combat_id, v_char1_id, v_char2_id, v_winner_id
    FROM Combats
    WHERE combat_id = p_combat_id;

    IF v_winner_id IS NOT NULL THEN
        RAISE EXCEPTION 'Combat % has already finished. Cannot reset round.', p_combat_id;
    END IF;

    -- 2. Get last combat_log for this combat
    SELECT round_num INTO v_round_num
    FROM combat_log
    WHERE combat_id = p_combat_id
    ORDER BY log_id DESC
    LIMIT 1;

    v_round_num := v_round_num + 1;

    -- 3. Get character 1 stats and calculate new AP
    SELECT dexterity, intelligence, c.action_points_modifier INTO v_dexterity1, v_intelligence1, v_ap_modifier1
    FROM character ch JOIN classes c ON ch.class_id = c.class_id
    WHERE ch.character_id = v_char1_id;
    v_new_ap1 := (v_dexterity1 + v_intelligence1) * v_ap_modifier1;

    -- 4. Get character 2 stats and calculate new AP
    SELECT dexterity, intelligence, c.action_points_modifier INTO v_dexterity2, v_intelligence2, v_ap_modifier2
    FROM character ch JOIN classes c ON ch.class_id = c.class_id
    WHERE ch.character_id = v_char2_id;
    v_new_ap2 := (v_dexterity2 + v_intelligence2) * v_ap_modifier2;

    -- 5. Update characters' action_points
    UPDATE character SET action_points = v_new_ap1 WHERE character_id = v_char1_id;
    UPDATE character SET action_points = v_new_ap2 WHERE character_id = v_char2_id;

    -- 6. Get current health
    SELECT health INTO v_char1_health FROM character WHERE character_id = v_char1_id;
    SELECT health INTO v_char2_health FROM character WHERE character_id = v_char2_id;

    -- 7. Insert into combat_log
    INSERT INTO combat_log (
        combat_id, round_num, event_num, event_type,
        char1_id, char2_id,
        char1_ap, char2_ap,
        char1_health, char2_health,
        d20_value, attack_damage, spell_id,
        char1_ap_after, char2_ap_after,
        char1_health_after, char2_health_after
    ) VALUES (
        v_combat_id, v_round_num, 0, 'reset_round',
        v_char1_id, v_char2_id,
        v_new_ap1, v_new_ap2,
        v_char1_health, v_char2_health,
        NULL, NULL, NULL,
        v_new_ap1, v_new_ap2,
        v_char1_health, v_char2_health
    );

    -- 8. Get new log_id for this combat
    SELECT log_id INTO v_new_log_id
    FROM combat_log
    WHERE combat_id = p_combat_id AND char1_id = v_char1_id AND char2_id = v_char2_id
    ORDER BY log_id DESC
    LIMIT 1;

    -- 9. Log all current arena items into Arena_Items_History with new log_id
    INSERT INTO Arena_Items_History (item_id, log_id)
    SELECT items_id, v_new_log_id
    FROM Arena_items_has_Items
    WHERE combat_id = p_combat_id;

    -- 10. Log current ownership for character 1
    INSERT INTO Item_Ownership_History (item_id, character_id, log_id)
    SELECT item_id, v_char1_id, v_new_log_id
    FROM Character_has_Items
    WHERE character_id = v_char1_id;

    -- 11. Log current ownership for character 2
    INSERT INTO Item_Ownership_History (item_id, character_id, log_id)
    SELECT item_id, v_char2_id, v_new_log_id
    FROM Character_has_Items
    WHERE character_id = v_char2_id;

END;
$$ LANGUAGE plpgsql;

--cast spell
CREATE OR REPLACE FUNCTION sp_cast_spell(
    p_caster_id INTEGER,
    p_target_id INTEGER,
    p_spell_id INTEGER 
) RETURNS VOID AS $$
DECLARE
    -- attacker
    v_caster_ap NUMERIC;
    v_caster_intelligence NUMERIC;
    v_caster_strength NUMERIC;
    v_caster_dexterity NUMERIC;
    v_caster_constitution NUMERIC;
    v_caster_health NUMERIC;
    v_caster_health_after NUMERIC;

    -- target
    v_target_health NUMERIC;
    v_target_health_after NUMERIC;
    v_target_ap NUMERIC;
    v_target_armor_class NUMERIC;

    -- class
    v_class_ap_modifier NUMERIC;
    v_class_damage_modifier NUMERIC;

    -- spell
    v_spell_ap_cost NUMERIC;
    v_spell_damage NUMERIC;
    v_effective_cost NUMERIC;
    v_modifying_attribute VARCHAR(45);
    v_mod_value NUMERIC;

    -- spell requirements
    v_required_strength NUMERIC;
    v_required_dexterity NUMERIC;
    v_required_intelligence NUMERIC;
    v_required_constitution NUMERIC;

    -- calcs
    v_d20_roll INT;
    v_attack_damage NUMERIC := 0;
    v_caster_ap_after NUMERIC;

    -- events
    v_combat_id INT;
    v_event_num INT;
    v_round_num INT;
    v_new_log_id INT;

    -- spell cost check
    v_caster_min_spell_cost NUMERIC;
    v_target_min_spell_cost NUMERIC;
BEGIN
    -- 1. Overenie, že existuje ongoing combat
    IF NOT EXISTS (
        SELECT 1
        FROM Combats
        WHERE ((char1_id = p_caster_id AND char2_id = p_target_id)
            OR (char2_id = p_caster_id AND char1_id = p_target_id))
          AND winner_id is null
    ) THEN
        RAISE EXCEPTION 'No ongoing combat found between characters % and %.', p_caster_id, p_target_id;
    END IF;

    -- 2. Get current combat_id
    SELECT combat_id INTO v_combat_id
    FROM Combats
    WHERE ((char1_id = p_caster_id AND char2_id = p_target_id)
        OR (char2_id = p_caster_id AND char1_id = p_target_id))
      AND winner_id is null
    LIMIT 1;

    -- 3. Get latest combat_log info for this combat
    SELECT round_num, event_num INTO v_round_num, v_event_num
    FROM combat_log
    WHERE combat_id = v_combat_id
    ORDER BY log_id DESC
    LIMIT 1;

    v_event_num := v_event_num + 1;

    -- 4. Get caster attributes
    SELECT ch.action_points, ch.intelligence, ch.strength, ch.dexterity, ch.constitution, ch.health
    INTO v_caster_ap, v_caster_intelligence, v_caster_strength, v_caster_dexterity, v_caster_constitution, v_caster_health
    FROM character ch
    WHERE ch.character_id = p_caster_id;

    -- 5. Get class modifiers
    SELECT c.action_points_modifier, c.damage_modifier
    INTO v_class_ap_modifier, v_class_damage_modifier
    FROM character ch
    JOIN classes c ON ch.class_id = c.class_id
    WHERE ch.character_id = p_caster_id;

    -- 6. Get spell data + requirements + modifying_attribute
    SELECT s.action_points_cost, s.damage,
           s.required_strength, s.required_dexterity, s.required_intelligence, s.required_constitution,
           s.modifying_attribute
    INTO v_spell_ap_cost, v_spell_damage,
         v_required_strength, v_required_dexterity, v_required_intelligence, v_required_constitution,
         v_modifying_attribute
    FROM spells s
    WHERE s.spell_id = p_spell_id;

    -- 7. Check attribute requirements
    IF v_caster_strength < v_required_strength OR
       v_caster_dexterity < v_required_dexterity OR
       v_caster_intelligence < v_required_intelligence OR
       v_caster_constitution < v_required_constitution THEN
        RAISE NOTICE 'Not enough attributes to cast the spell.';
        RETURN;
    END IF;

    -- 8. Get target info
    SELECT ch.health, ch.armor_class, ch.action_points
    INTO v_target_health, v_target_armor_class, v_target_ap
    FROM character ch
    WHERE ch.character_id = p_target_id;

    -- 9. Calculate effective cost
    v_effective_cost := f_effective_spell_cost(p_spell_id, p_caster_id);

    -- 10. Check AP
    IF v_caster_ap < v_effective_cost THEN
        RAISE NOTICE 'Not enough AP to cast the spell.';
        RETURN;
    END IF;

    -- 11. Roll for attack
    v_d20_roll := FLOOR(random() * 20 + 1);

    -- 12. Calculate new AP for caster
    v_caster_ap_after := v_caster_ap - v_effective_cost;

    -- 13. Determine value of modifying attribute
    IF v_modifying_attribute = 'strength' THEN
        v_mod_value := v_caster_strength;
    ELSIF v_modifying_attribute = 'dexterity' THEN
        v_mod_value := v_caster_dexterity;
    ELSIF v_modifying_attribute = 'constitution' THEN
        v_mod_value := v_caster_constitution;
    ELSIF v_modifying_attribute = 'intelligence' THEN
        v_mod_value := v_caster_intelligence;
    ELSE
        v_mod_value := 0; -- fallback
    END IF;

    -- 14. Calculate damage
    IF v_d20_roll > v_target_armor_class THEN
        v_attack_damage := v_spell_damage * (1 + ((v_class_damage_modifier + v_caster_strength + v_mod_value) / 20.0));
    ELSE
        v_attack_damage := 0;    
    END IF;

    -- 15. Calculate new health values
    v_target_health_after := GREATEST(v_target_health - v_attack_damage, 0);
    v_caster_health_after := v_caster_health;

    -- 16. Insert into combat_log
    INSERT INTO combat_log (
        combat_id, round_num, event_num, event_type,
        char1_id, char2_id,
        char1_ap, char2_ap,
        char1_health, char2_health,
        d20_value, attack_damage, spell_id,
        char1_ap_after, char2_ap_after,
        char1_health_after, char2_health_after
    ) VALUES (
        v_combat_id, v_round_num, v_event_num, 'spell_attack',
        p_caster_id, p_target_id,
        v_caster_ap, v_target_ap,
        v_caster_health, v_target_health,
        v_d20_roll, v_attack_damage, p_spell_id,
        v_caster_ap_after, v_target_ap,
        v_caster_health_after, v_target_health_after
    );

    -- 17. Get new log_id via SELECT
    SELECT log_id INTO v_new_log_id
    FROM combat_log
    WHERE combat_id = v_combat_id
    ORDER BY log_id DESC
    LIMIT 1;

    -- 18. Update characters
    UPDATE character SET action_points = v_caster_ap_after WHERE character_id = p_caster_id;
    UPDATE character SET health = v_target_health_after WHERE character_id = p_target_id;

    -- 19. Log Arena_Items_History
    INSERT INTO Arena_Items_History (item_id, log_id)
    SELECT items_id, v_new_log_id
    FROM Arena_items_has_Items
    WHERE combat_id = v_combat_id;

    -- 20. Log Item_Ownership_History for caster
    INSERT INTO Item_Ownership_History (item_id, character_id, log_id)
    SELECT item_id, p_caster_id, v_new_log_id
    FROM Character_has_Items
    WHERE character_id = p_caster_id;

    -- 21. Log Item_Ownership_History for target
    INSERT INTO Item_Ownership_History (item_id, character_id, log_id)
    SELECT item_id, p_target_id, v_new_log_id
    FROM Character_has_Items
    WHERE character_id = p_target_id;

    -- 22. Check if target is dead
    IF v_target_health_after <= 0 THEN
        PERFORM sp_rest_character(p_caster_id, p_target_id);
    END IF;

    -- 23. Over kalkuláciu minimálneho spell costu pre reset round:
    -- Caster
    SELECT MIN(f_effective_spell_cost(s.spell_id, p_caster_id))
    INTO v_caster_min_spell_cost
    FROM spells s
    WHERE s.required_strength <= v_caster_strength
      AND s.required_dexterity <= v_caster_dexterity
      AND s.required_intelligence <= v_caster_intelligence
      AND s.required_constitution <= v_caster_constitution;

    -- Target
    SELECT MIN(f_effective_spell_cost(s.spell_id, p_target_id))
    INTO v_target_min_spell_cost
    FROM spells s
    JOIN character ch ON ch.character_id = p_target_id
    WHERE s.required_strength <= ch.strength
      AND s.required_dexterity <= ch.dexterity
      AND s.required_intelligence <= ch.intelligence
      AND s.required_constitution <= ch.constitution;

    -- 24. Reset round podmienka
    IF (v_caster_ap_after < v_caster_min_spell_cost OR v_caster_min_spell_cost IS NULL)
       AND (v_target_ap < v_target_min_spell_cost OR v_target_min_spell_cost IS NULL) THEN
        PERFORM sp_reset_round(v_combat_id);
    END IF;

END;
$$ LANGUAGE plpgsql;



--loot item
CREATE OR REPLACE FUNCTION sp_loot_item (
    p_combat_id INT,
    p_character_id INT,
    p_item_id INT
) RETURNS VOID AS $$
DECLARE
    v_capacity NUMERIC;
    v_capacity_reached NUMERIC;
    v_item_weight NUMERIC;
    v_event_num INT;
    v_round_num INT;

    v_new_log_id INT;
    v_item_in_arena BOOLEAN;
BEGIN

	IF NOT EXISTS (
	    SELECT 1
	    FROM Combats
	    WHERE combat_id = p_combat_id
	) THEN
	    RAISE EXCEPTION 'Combat % does not exist.', p_combat_id;
	END IF;
	
    -- 1. check if combat is going and has correct characters
    IF NOT EXISTS (
        SELECT 1
        FROM Combats
        WHERE combat_id = p_combat_id
          AND winner_id is null
          AND (char1_id = p_character_id OR char2_id = p_character_id)
    ) THEN
        RAISE EXCEPTION 'Character % is not in combat % or combat is already finished.', p_character_id, p_combat_id;
    END IF;

    -- 2. if item is in arena
    SELECT EXISTS (
        SELECT 1 FROM arena_items_has_items
        WHERE combat_id = p_combat_id AND items_id = p_item_id
    ) INTO v_item_in_arena;

    IF NOT v_item_in_arena THEN
        RAISE NOTICE 'Item % is not in the arena for combat %.', p_item_id, p_combat_id;
        RETURN;
    END IF;

    -- 3. capacities
    SELECT inventory_capacity, inventory_capacity_reached
    INTO v_capacity, v_capacity_reached
    FROM character
    WHERE character_id = p_character_id;

    -- 4. weights
    SELECT weight INTO v_item_weight
    FROM items
    WHERE item_id = p_item_id;

    -- 5. check capacity
    IF v_capacity_reached + v_item_weight > v_capacity THEN
        RAISE NOTICE 'No space in inventory: %/% + item (%).', v_capacity_reached, v_capacity, v_item_weight;
        RETURN;
    END IF;

    -- 6. update inventory_capacity_reached
    UPDATE character
    SET inventory_capacity_reached = inventory_capacity_reached + v_item_weight
    WHERE character_id = p_character_id;

    -- 7. insert (Character_has_Items)
    INSERT INTO Character_has_Items (character_id, item_id)
    VALUES (p_character_id, p_item_id);

    -- 8. get last log
    SELECT round_num, event_num
    INTO v_round_num, v_event_num
    FROM combat_log
    WHERE combat_id = p_combat_id
    ORDER BY log_id DESC
    LIMIT 1;

    v_event_num := v_event_num + 1;

    -- 9. insert new record
    INSERT INTO combat_log (
        combat_id, round_num, event_num, event_type,
        char1_id, char2_id,
        char1_ap, char2_ap,
        char1_health, char2_health,
        d20_value, attack_damage,
        item_id, spell_id,
        char1_ap_after, char2_ap_after,
        char1_health_after, char2_health_after
    ) VALUES (
        p_combat_id, v_round_num, v_event_num, 'loot_item',
        p_character_id, NULL,
        NULL, NULL,
        NULL, NULL,
        NULL, NULL,
        p_item_id, NULL,
        NULL, NULL,
        NULL, NULL
    );

    -- 10. get log_id
    SELECT log_id INTO v_new_log_id
    FROM combat_log
    ORDER BY log_id DESC
    LIMIT 1;

    -- 11. remove item from arena
    DELETE FROM Arena_items_has_Items
    WHERE combat_id = p_combat_id AND items_id = p_item_id;

    -- 12. log history
    INSERT INTO Arena_Items_History (item_id, log_id)
    SELECT items_id, v_new_log_id
    FROM Arena_items_has_Items
    WHERE combat_id = p_combat_id;

    -- 13. log chaarcter items
    INSERT INTO Item_Ownership_History (item_id, character_id, log_id)
    SELECT item_id, p_character_id, v_new_log_id
    FROM Character_has_Items
    WHERE character_id = p_character_id;

END;
$$ LANGUAGE plpgsql;

--
--effective cost
CREATE OR REPLACE FUNCTION f_effective_spell_cost(
    p_spell_id INT,
    p_caster_id INT
) RETURNS NUMERIC AS $$
DECLARE
    v_spell_ap_cost NUMERIC;
    v_class_ap_modifier NUMERIC;
    v_caster_intelligence NUMERIC;
    v_effective_cost NUMERIC;
BEGIN
    -- base cost
    SELECT action_points_cost INTO v_spell_ap_cost 
    FROM spells 
    WHERE spell_id = p_spell_id;

    -- modifier and intelligence
    SELECT c.action_points_modifier, ch.intelligence
    INTO v_class_ap_modifier, v_caster_intelligence
    FROM character ch
    JOIN classes c ON ch.class_id = c.class_id
    WHERE ch.character_id = p_caster_id;

    -- if maybe null
    v_class_ap_modifier := COALESCE(v_class_ap_modifier, 0);
    v_caster_intelligence := COALESCE(v_caster_intelligence, 0);

    -- calc
    v_effective_cost := v_spell_ap_cost * (1 - ((v_class_ap_modifier + v_caster_intelligence) / 100.0));

    -- 
    RETURN v_effective_cost;
END;
$$ LANGUAGE plpgsql;


---------------------------------------------------------
--testing testing testing
---------------------------------------------------------


INSERT INTO Classes (class_name, action_points_modifier, damage_modifier, inventory_bonus)
VALUES 
('Warrior', 1.0, 1.2, 1),
('Mage', 1.2, 1.5, 2),
('Rogue', 1.1, 1.3, 1);


INSERT INTO Items (item_name, damage, weight, action_points_cost)
VALUES 
('Sword', 10, 3, 2),
('Shield', 5, 5, 1),
('poison', 5, 1, 2),
('Magic Staff', 12, 4, 3),
('Dagger', 8, 2, 1),
('Axe', 20, 15, 3),
('Bow', 18, 12, 4),
('Brick', 4, 8, 2),
('Arrow', 2, 5, 2),
('Knife', 3, 5, 2),
('Knife 2', 3, 5, 2),
('Knife 3', 3, 5, 2),
('Knife 4', 3, 5, 2);


INSERT INTO Spells (spell_name, damage, action_points_cost, required_strength, required_dexterity, required_constitution, required_intelligence, modifying_attribute)
VALUES 
('Fireball', 20, 5, 0, 0, 0, 5, 'intelligence'),
('Ice Spike', 15, 4, 0, 4, 0, 0, 'dexterity'),
('Mega Blast', 50, 10, 10, 10, 10, 10, 'strength'); -- too expensive


INSERT INTO Character (character_name, action_points, armor_class, class_id, strength, dexterity, constitution, intelligence, max_health, health, inventory_capacity, inventory_capacity_reached)
VALUES 
('TiredOne', 5, 10, 1, 4, 5, 5, 5, 80, 80, 15, 0),
('TiredTwo', 4, 12, 2, 3, 6, 4, 6, 70, 70, 15, 0);

INSERT INTO Character (character_name, action_points, armor_class, class_id, strength, dexterity, constitution, intelligence, max_health, health, inventory_capacity, inventory_capacity_reached)
VALUES ('LowHealthGuy', 10, 12, 1, 5, 5, 5, 5, 50, 2, 20, 0);

INSERT INTO Character (character_name, action_points, armor_class, class_id, strength, dexterity, constitution, intelligence, max_health, health, inventory_capacity, inventory_capacity_reached)
VALUES ('FullBackpack', 12, 13, 3, 5, 5, 5, 5, 70, 70, 10, 9);

INSERT INTO Character (character_name, action_points, armor_class, class_id, strength, dexterity, constitution, intelligence, max_health, health, inventory_capacity, inventory_capacity_reached)
VALUES ('BalancedHero', 15, 15, 2, 6, 6, 6, 6, 90, 90, 20, 5);

INSERT INTO Character (character_name, action_points, armor_class, class_id, strength, dexterity, constitution, intelligence, max_health, health, inventory_capacity, inventory_capacity_reached)
VALUES ('StrongMage', 18, 19, 2, 4, 6, 5, 9, 85, 85, 18, 12);


INSERT INTO Character_has_Items (character_id, item_id) VALUES (4, 4);  
INSERT INTO Character_has_Items (character_id, item_id) VALUES (4, 5);  
INSERT INTO Character_has_Items (character_id, item_id) VALUES (4, 8);  

INSERT INTO Character_has_Items (character_id, item_id) VALUES (5, 10); 
INSERT INTO Character_has_Items (character_id, item_id) VALUES (6, 7); 

-------------------------
--display samples
select * from combat_log
select * from character
select * from combats
select * from item_ownership_history
select * from character_has_items
select * from arena_items_history
select * from arena_items_has_items

---------------------
--combat log
---------------------

SELECT sp_enter_combat(1, 6, 3);
SELECT sp_cast_spell(6, 3, 1); -- StrongMage kills LowHealthGuy
--rest character expected

SELECT sp_enter_combat(1, 6, 3); -- trying to enter same combat (exception)


SELECT sp_enter_combat(2, 1, 2);  -- Combat 2: TiredOne vs TiredTwo
SELECT sp_cast_spell(1, 2, 1);  -- Fireball (intelligence 5, AP 5, empty AP)
SELECT sp_cast_spell(2, 1, 2);  -- Ice Spike (dexterity 6, AP 4, empty AP)
--reset round expected

SELECT sp_cast_spell(1, 2, 1);
SELECT sp_cast_spell(1, 2, 3); --expensive spell (cast unsuccesful)


SELECT sp_enter_combat(3, 5, 4);  -- Combat 3: BalancedHero vs FullBackpack  trying to push more combats at the time
SELECT sp_loot_item(3, 5, 3);  -- loot item (succesful)
SELECT sp_loot_item(3, 4, 13);  -- looting with full inventory (not succesful).
SELECT sp_loot_item(3, 5, 6);  -- looting item not in arena (not succesful).

select sp_loot_item(2, 1, 9);

select sp_loot_item(2, 10, 9); -- call function for chaarcter that is not in this combat
select sp_cast_spell(5, 4, 1); -- test for another cast in combat 3 (success expected) (exactly 2 with damage 0 (because armor class) 3rd with damage)
select sp_loot_item(10, 4, 9); --test for loot in non existing combat


--------------------------------------------------
TRUNCATE TABLE --restart tables if needed
    Arena_Items_History,
    Item_Ownership_History,
    Combat_log,
    Arena_items_has_Items,
    Character_has_Items,
    Combats,
    Character,
    Items,
    Spells,
    Classes
RESTART IDENTITY CASCADE;
--restart sequences if needed
ALTER SEQUENCE classes_class_id_seq RESTART WITH 1;
ALTER SEQUENCE items_item_id_seq RESTART WITH 1;
ALTER SEQUENCE spells_spell_id_seq RESTART WITH 1;
ALTER SEQUENCE character_character_id_seq RESTART WITH 1;
ALTER SEQUENCE combats_combat_id_seq RESTART WITH 1;
ALTER SEQUENCE combat_log_log_id_seq RESTART WITH 1;
ALTER SEQUENCE item_ownership_history_history_id_seq RESTART WITH 1;
ALTER SEQUENCE arena_items_history_arena_history_id_seq RESTART WITH 1;

--------------------------------------------------
--call views
select * from view_combat_damage
select * from view_combat_state
select * from view_spell_statistics
select * from view_strongest_characters
select * from view_most_damage