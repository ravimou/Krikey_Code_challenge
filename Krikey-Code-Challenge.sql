/*
Declared TABLE schema are as below

----------
game_items
----------
id                      uuid
item_type               enum_game_item_type
display_name            varchar
spendables_required     json

------------
transactions
------------
id                      uuid
user_id                 uuid
received                json
spent                   json

---------
locations
---------
id      uuid
geom    geometry

*/

/*
1. What should be the CREATE statement for a new table game_item_locations that
consists of different game_items assigned to locations per user_id?
*/
CREATE TABLE IF NOT EXISTS game_item_locations (
    id uuid NOT NULL PRIMARY KEY,
	user_id uuid NOT NULL,
	location_id uuid NOT NULL,
    FOREIGN KEY user_id REFERENCES users(id)
    FOREIGN KEY location_id REFERENCES locations(id)
);

/*
2. Insert dummy data for for transactions, locations, game_item_locations (5k rows for each
table for 100 different user_ids)

based on the datatype postgres has functions like `random()::text`, `random()::uuid` to generate random and prefill the tabe.
*/

/*
3. Which user has received the downy woodpecker the most often?
*/
DECLARE
    downy_woodpecker_id uuid;
BEGIN
    SELECT id INTO downy_woodpecker_id FROM game_items WHERE display_name = 'downy woodpecker';
    
    SELECT t.user_id as user_id, d.key as item_id, SUM(d.value) AS total 
    FROM transactions as t , json_each(transactions.received) as d 
    WHERE item_id=downy_woodpecker_id 
    GROUP BY item_id 
    ORDER BY total DESC 
    LIMIT 1;
END

/*
4. What are the aggregated counts per item for each user or itemCounts? By this
itemCount we mean, aggregating the values of transactions.received for each item key
and then subtracting the aggregated values of transactions.spent for each item key. We
call this collection of itemCounts per user the user’s player-state. The player-state for
user_id ba637a13-4ae0-45c0-b36a-06e762b4d46f, for example, looks like:
*/

/*
Part 2: API Scaling
-------------------
2.1 How would you scale calculating player state for 50,000 concurrent requests? Would you
introduce any new technologies?

Hosting a single instance of backend application where the 'Player state' API is implemented
and making the endpoint to handle 50k concurrent requests will lead to a failed state due to 
throttling issue on API's. It can be solved by,

1) Introducting multiple instances hosted with the same backend application running
and putting a load balancer that distributes requests between instances based on some request distribution mapping 
technique(eg. round robin) between instances would distribute the request load between instances and reduce the cases of failure.

---------------------
2.2 How would you reduce how long it takes the item locations query from part one to run? If
the query is exposed as an API endpoint, how would you scale it for 50,000 concurrent
requests?

By introducing column indexes on 'user_id' column in transactions table will speed up the execution of sql stored procedures 
responsible for retriving the details from 'game_item_locations' table. Then following the above mentioned techniques in 1) 
will handle the concurrent requests.
*/