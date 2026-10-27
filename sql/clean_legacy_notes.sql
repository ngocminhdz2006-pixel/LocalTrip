USE LocalTripDB;
GO

UPDATE ItineraryItems
SET note = CASE 
    WHEN note LIKE '%Dining%Group Match%' THEN 
        'Dining • ' + SUBSTRING(note, CHARINDEX('% Group Match', note) - 2, 2) + '% Group Match'
    WHEN note LIKE '%Cafe & Drinks%Group Match%' THEN 
        'Cafe & Drinks • ' + SUBSTRING(note, CHARINDEX('% Group Match', note) - 2, 2) + '% Group Match'
    WHEN note LIKE '%Sightseeing%Group Match%' THEN 
        'Sightseeing • ' + SUBSTRING(note, CHARINDEX('% Group Match', note) - 2, 2) + '% Group Match'
    WHEN note LIKE '%Entertainment%Group Match%' THEN 
        'Entertainment • ' + SUBSTRING(note, CHARINDEX('% Group Match', note) - 2, 2) + '% Group Match'
    WHEN note LIKE '%Shopping%Group Match%' THEN 
        'Shopping • ' + SUBSTRING(note, CHARINDEX('% Group Match', note) - 2, 2) + '% Group Match'
    ELSE note
END
WHERE note LIKE '%Group Match%';
GO
