const axios = require('axios');

const ACCESS_TOKEN = 'APP_USR-2562332165830331-030619-6d7d67f29e093f410a1e9f63dc5a617c-114513661';

async function createTestLink() {
  const payload = {
    items: [
      {
        title: "Test de Integración FeelTrip",
        quantity: 1,
        unit_price: 100,
        currency_id: "CLP"
      }
    ],
    back_urls: {
      success: "feeltrip://payments/success",
      failure: "feeltrip://payments/failure",
      pending: "feeltrip://payments/pending"
    },
    auto_return: "approved"
  };

  try {
    const response = await axios.post(
      'https://api.mercadopago.com/checkout/preferences',
      payload,
      {
        headers: {
          'Authorization': `Bearer ${ACCESS_TOKEN}`,
          'Content-Type': 'application/json'
        }
      }
    );
    console.log('--- LINK DE PRUEBA GENERADO ---');
    console.log(response.data.init_point);
    console.log('-------------------------------');
  } catch (error) {
    console.error('Error:', error.response ? error.response.data : error.message);
  }
}

createTestLink();
