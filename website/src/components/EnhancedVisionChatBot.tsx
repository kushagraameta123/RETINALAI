import { AlertTriangle, Brain, Send, User } from 'lucide-react';
import React, { useEffect, useRef, useState } from 'react';
import ReactMarkdown from 'react-markdown';
import { supabase } from '../services/supabaseClient';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { Input } from './ui/input';

// Define the structure of a message
interface Message {
  text: string;
  isUser: boolean;
}

export default function EnhancedVisionChatBot() {
  const [messages, setMessages] = useState<Message[]>([
    { text: "Welcome to the **Retinal-AI Vision Assistant**. How can I help you understand retinal health today?", isUser: false }
  ]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const chatEndRef = useRef<HTMLDivElement>(null);

  // Automatically scroll to the latest message
  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const examplePrompts = [
    "What is Diabetic Retinopathy?",
    "Signs of Glaucoma",
    "What are Drusen?",
    "Explain Macular Degeneration"
  ];

  const handleSend = async (promptText = input) => {
    if (!promptText.trim() || isLoading) return;

    // --- THIS IS THE FIX: This line adds your question to the chat history ---
    const userMessage: Message = { text: promptText, isUser: true };
    setMessages(prev => [...prev, userMessage]);
    
    setInput('');
    setIsLoading(true);

    try {
      const { data, error } = await supabase.functions.invoke('ask-ai', {
        body: { prompt: promptText },
      });

      if (error) throw error;

      const aiMessage: Message = { text: data.response, isUser: false };
      setMessages(prev => [...prev, aiMessage]);

    } catch (error) {
      console.error('Error calling Edge Function:', error);
      const errorMessage: Message = { text: 'I seem to be having trouble connecting. Please try again in a moment.', isUser: false };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleFormSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    handleSend();
  };

  return (
    <div className="flex justify-center items-center py-12 bg-slate-50">
      <Card className="w-full max-w-3xl h-[85vh] flex flex-col shadow-2xl rounded-2xl bg-white/80 backdrop-blur-xl border border-white/30">
        
        <div className="p-4 border-b border-white/20 flex items-center justify-between bg-white/50 rounded-t-2xl">
          <div className="flex items-center space-x-4">
            <div className="relative">
              <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-full flex items-center justify-center shadow-lg">
                <Brain className="w-6 h-6 text-white" />
              </div>
              <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-green-400 border-2 border-white rounded-full animate-pulse"></div>
            </div>
            <div>
              <h2 className="font-bold text-xl text-gray-800 tracking-wide">AI Vision Assistant</h2>
              <p className="text-sm text-gray-500">Powered by Gemini AI</p>
            </div>
          </div>
        </div>

        <CardContent className="flex-1 overflow-y-auto p-6 space-y-8 bg-slate-50">
          {messages.map((msg, index) => (
            <div key={index} className={`flex items-start gap-4 ${msg.isUser ? 'justify-end' : ''}`}>
              {!msg.isUser && (
                <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center flex-shrink-0 shadow-md">
                  <Brain className="w-5 h-5 text-white" />
                </div>
              )}
              <div className={`max-w-lg p-4 rounded-3xl shadow-md transition-all duration-300 ${
                  msg.isUser
                    ? 'bg-blue-600 text-black rounded-br-lg'
                    : 'bg-blue-600 text-black rounded-br-lg'
                }`}
              >
                <div className="prose prose-sm text-inherit max-w-none">
                  <ReactMarkdown>{msg.text}</ReactMarkdown>
                </div>
              </div>
              {msg.isUser && (
                <div className="w-10 h-10 rounded-full bg-slate-200 flex items-center justify-center flex-shrink-0 shadow-md">
                  <User className="w-5 h-5 text-slate-600" />
                </div>
              )}
            </div>
          ))}
          {isLoading && (
             <div className="flex items-start gap-4">
               <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center flex-shrink-0 shadow-md">
                  <Brain className="w-5 h-5 text-white" />
                </div>
              <div className="max-w-md p-4 rounded-3xl bg-white text-gray-800 rounded-bl-lg shadow-md">
                <div className="flex items-center space-x-2">
                  <span className="text-sm font-medium">Vision is thinking</span>
                  <div className="w-2 h-2 bg-blue-400 rounded-full animate-pulse"></div>
                  <div className="w-2 h-2 bg-blue-400 rounded-full animate-pulse delay-75"></div>
                  <div className="w-2 h-2 bg-blue-400 rounded-full animate-pulse delay-150"></div>
                </div>
              </div>
            </div>
          )}
          <div ref={chatEndRef} />
        </CardContent>

        <div className="p-4 border-t bg-white/60 rounded-b-2xl">
          <div className="flex flex-wrap gap-2 mb-4">
            {examplePrompts.map(prompt => (
              <Button key={prompt} variant="outline" size="sm" onClick={() => handleSend(prompt)} disabled={isLoading} className="bg-white/50 border-gray-300 hover:bg-slate-100">
                {prompt}
              </Button>
            ))}
          </div>
          <form onSubmit={handleFormSubmit} className="flex items-center gap-3">
            <Input 
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Ask about a retinal condition..."
              className="flex-1 bg-white/70 rounded-full focus:ring-2 focus:ring-blue-500"
              disabled={isLoading}
            />
            <Button type="submit" size="icon" className="rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 shadow-lg hover:scale-105 transition-transform" disabled={isLoading || !input.trim()}>
              <Send className="h-5 w-5" />
            </Button>
          </form>
          <div className="mt-4 p-3 bg-amber-100 text-amber-800 rounded-lg text-xs flex items-start space-x-2">
            <AlertTriangle className="h-4 w-4 mt-0.5 flex-shrink-0" />
            <p><strong>Medical Disclaimer:</strong> This AI assistant is for informational purposes only and is not a substitute for professional medical advice.</p>
          </div>
        </div>
      </Card>
    </div>
  );
}