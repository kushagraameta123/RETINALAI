import { GoogleGenerativeAI } from 'https://esm.sh/@google/generative-ai'

// CORS headers to allow your web app to call this function
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  // This is needed for CORS preflight requests.
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { prompt } = await req.json()
    const GOOGLE_AI_API_KEY = Deno.env.get('GOOGLE_AI_API_KEY')
    if (!GOOGLE_AI_API_KEY) {
      throw new Error('Missing Google AI API Key')
    }

    const genAI = new GoogleGenerativeAI(GOOGLE_AI_API_KEY)
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' })

    const systemPrompt = `You are Vision, a helpful AI assistant for Retinal-AI, a medical diagnosis platform. 
      Your purpose is to provide clear, educational information about eye health and retinal conditions. 
      Always include a disclaimer that you are not a substitute for a real doctor. Do not provide a diagnosis. 
      Use markdown for formatting.`

    const chat = model.startChat({
      history: [{ role: 'user', parts: [{ text: systemPrompt }] }],
    })

    const result = await chat.sendMessage(prompt)
    const response = await result.response
    const text = response.text()

    return new Response(JSON.stringify({ response: text }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})