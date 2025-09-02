class ProfileMockData {
  static final List<Map<String, dynamic>> posts = [
    {
      'title': '타이틀타이틀타이틀타이틀타이틀..',
      'content': '내용내용내용내용내용내용내용내용\n내용내용내용내용내용내용내용내용...',
      'category': '멍청스',
      'mode': 'punch',
      'imageUrl': 'https://picsum.photos/100/100',
      'date': '2025-08-28 19:00',
      'commentCount': 10,
    },
    {
      'title': '오늘 정말 힘든 하루였어요',
      'content': '회사에서 일이 너무 많아서 스트레스 받네요...',
      'category': '대박스',
      'mode': 'empathy',
      'imageUrl': 'https://picsum.photos/100/100',
      'date': '2025-08-27 22:15',
      'commentCount': 3,
    },
  ];

  static final List<Map<String, dynamic>> comments = [
    {
      'content': '정말 공감되는 글이네요! 저도 비슷한 경험이 있어요.',
      'postTitle': '오늘 하루 정말 힘들었다...',
      'date': '2025-08-28 20:30',
    },
    {
      'content': '그건 좀 아닌 것 같은데요? 다시 생각해보세요.',
      'postTitle': '이런 생각 어때요?',
      'date': '2025-08-27 18:45',
    },
  ];

  static final List<Map<String, dynamic>> likes = [];
}
