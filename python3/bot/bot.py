#!/usr/bin/env python3
channel_id = '-XXXXXX'
user_id='XXXXX'
bot_token = 'XXXXX:AAH_XXXXXXXXXXXXXXXXXXXXXX'
import telebot
from telebot import types
import base64
import requests
import json
import re
bot = telebot.TeleBot(bot_token)
title=''
text=''

# WordPress XML-RPC settings
url = "https://xxx.xxx/wp-json/wp/v2/posts"
wordpress_user = "xxx"
wordpress_password = "xxx xxx xxx xxx xxx xxx"
wordpress_credentials = wordpress_user + ":" + wordpress_password
wordpress_token = base64.b64encode(wordpress_credentials.encode())
wordpress_header = {'Authorization': 'Basic ' + wordpress_token.decode('utf-8')}
markup_start = types.ReplyKeyboardMarkup(resize_keyboard=True)
btn1 = types.KeyboardButton("/start")
markup_start.add(btn1)
bot.send_message(user_id,text="Бот запущен. Нажмите start", reply_markup=markup_start)

@bot.message_handler(commands=['start'])
def send_welcome(message):
    #bot.reply_to(message, 'Привет! Я могу отправлять сообщения в канал.')
        markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
        btn1 = types.KeyboardButton("Добавить запись")
        btn2 = types.KeyboardButton("Что я могу?")
        back = types.KeyboardButton("Вернуться в главное меню")
        markup.add(btn1, btn2, back)
        bot.send_message(message.chat.id, text="Привет. Чем займемся?", reply_markup=markup)

#@bot.message_handler(content_types=['text'])
#@bot.message_handler(commands=['Добавить запись'])
@bot.message_handler(content_types=['text'])
def func (message):
    if message.text == 'Добавить запись':
       send_note(message);
def send_note(message):
    if message.text:
        bot.send_message(message.from_user.id, "Введите тему записи", "html",reply_markup=types.ReplyKeyboardRemove());
        bot.register_next_step_handler(message, get_title);
    #elif message.photo:
    #    bot.send_photo(channel_id, message.photo[0].file_id);
def get_title(message):
    global title;
    global raw_title;
    if message.text:
        bot.send_message(message.from_user.id, "Введите текст записи", "html",reply_markup=types.ReplyKeyboardRemove());
        raw_title=message.text;
        title='<b>'+message.text+'</b>';
        bot.register_next_step_handler(message, get_text);
def get_text(message):
    global text;
       
    if message.text:
       text = message.text;
       bot.send_message(channel_id, title + '\n' +  text, "html", disable_notification=True);
       bot.register_next_step_handler(message, finish);

    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    btn1 = types.KeyboardButton("Добавить на сайт")
    btn2 = types.KeyboardButton("Вернуться в главное меню")
    markup.add(btn1, btn2)
    bot.send_message(message.chat.id, "Заметка отправлена в канал.", reply_markup=markup);

def finish(message):
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    btn2 = types.KeyboardButton("Вернуться в главное меню")
    markup.add(btn2)

    """ hash_list = re.findall("#(\w+)", text)
    print(hash_list)
    post = {
        'title': raw_title,
        'content': text,
        'status': 'draft',
        'tags':hash_list
    } """

    if message.text=='Добавить на сайт':
       post = {
           'title': raw_title,
           'content': text,
           'status': 'draft',
           'tags':[276]
       }
       response = requests.post(url, headers=wordpress_header, json=post)
       bot.send_message(message.chat.id, "Отправлено на сайт");
       send_welcome(message)
    elif message.text=='Вернуться в главное меню':
       send_welcome(message)
bot.polling()
