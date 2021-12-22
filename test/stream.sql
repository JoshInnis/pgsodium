BEGIN;
SELECT plan(6);

select crypto_stream_xchacha20_noncegen() secretnonce \gset
select crypto_stream_xchacha20_keygen() secretkey \gset

select crypto_stream_xchacha20_xor('bob is your uncle', :'secretnonce', :'secretkey') secret \gset

SELECT throws_ok(format($$select crypto_stream_xchacha20_xor(%L, 'bad nonce', %L::bytea)$$, :'secret', :'secretkey'),
	   	         '22000', 'invalid nonce', 'crypto_stream invalid nonce');

SELECT throws_ok(format($$select crypto_stream_xchacha20_xor(%L, %L, 'bad_key'::bytea)$$, :'secret', :'secretnonce'),
	   	         '22000', 'invalid key', 'crypto_stream invalid key');

SELECT is(crypto_stream_xchacha20_xor(:'secret', :'secretnonce', :'secretkey'::bytea),
          'bob is your uncle', 'crypto_stream xor decryption');

select crypto_stream_xchacha20_xor_ic('bob is your uncle', :'secretnonce', 42, :'secretkey') secret \gset

SELECT throws_ok(format($$select crypto_stream_xchacha20_xor_ic(%L, 'bad nonce', 42, %L::bytea)$$, :'secret', :'secretkey'),
	   	         '22000', 'invalid nonce', 'crypto_stream invalid nonce');

SELECT throws_ok(format($$select crypto_stream_xchacha20_xor_ic(%L, %L, 42, 'bad_key'::bytea)$$, :'secret', :'secretnonce'),
	   	         '22000', 'invalid key', 'crypto_stream invalid key');

SELECT is(crypto_stream_xchacha20_xor_ic(:'secret', :'secretnonce', 42, :'secretkey'::bytea),
          'bob is your uncle', 'crypto_stream xor decryption');

SELECT * FROM finish();
ROLLBACK;
